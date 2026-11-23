// This function transforms a list of Bézier control points to a list of Bézier segments.
// A single Bézier segment has 4 control points: the start, two points that determine the curvature, and the end.
// When the curve consists of only one segment, the length is 4,
// and for more than one segment, the length must be 7, 10, 13, 16, ...
// For example, when points = (p0, p1, p2, p3, p4, p5, p6, p7, p8, p9),
// we get:
// ((p0, p1, p2, p3), (p3, p4, p5, p6), (p6, p7, p8, p9))
#let bezier-segments(points) = {
  if (calc.rem(points.len() - 1, 3) != 0) {
    panic("Length of input must follow formula \"(len - 1) % 3 == 0\", but was " + str(points.len()))
  }
  let segments = ()
  let i = 0
  while i + 3 < points.len() {
    segments.push(points.slice(i, i + 4))
    i += 3
  }
  segments
}

#let test-bezier-segments() = {
  let points = ((0,0),(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9))
  let expected-result = (((0,0),(1,1),(2,2),(3,3)),((3,3),(4,4),(5,5),(6,6)),((6,6),(7,7),(8,8),(9,9)))
  assert(bezier-segments(points) == expected-result)
}

#let panic-on-bezier-incorrect-length() = {
  bezier-segments(((0,0),(1,1),(2,2)))
}

#let replace-bounds(points, new-start, new-end) = {
  if (points.len() < 2) {
    panic("Length must be greater than 2.")
  }
  (new-start, ..points.slice(1, -1), new-end)
}
