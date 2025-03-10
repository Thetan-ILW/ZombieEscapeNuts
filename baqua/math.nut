local math = {
    huge = (2 << 53).tofloat()

    function min(a, b) {
        if (a > b)
            return b
        return a
    }

    function max(a, b) {
        if (a > b)
            return a
        return b
    }

    function clamp(v, a, b) {
        return math.min(math.max(v, a), b)
    }

    function round(x, to) {
        if ((x / to) % 1.0 < 0.5) {
            return floor(x / to) * to
        }
        else {
            return ceil(x / to) * to
        }
    }
}

module <- math