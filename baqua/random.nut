class LehmerRng {
    seed = 1
    a = 16807
    m = 2147483647
    q = 127773
    r = 2836

    constructor(seed = null) {
        if (seed == null) {
            local time = {}
            LocalTime(time)

            seed = Time()
            foreach(k, v in time) {
                seed += v + RandomInt(1, 32768)
            }
        }

        if (seed <= 0) {
            error("Bad seed")
        }
        this.seed = ceil(seed)
    }

    // Returns [0; 1) !!!!!!!!!!
    function next() {
        local hi = seed / q
        local lo = seed % q
        this.seed = (a * lo) - (r * hi)
        if (this.seed <= 0) {
            this.seed = this.seed + m
        }
        return (this.seed * 1.0) / m
    }

    // Returns [min; max]
    function nextInt(min, max) {
        return min + floor((max - min + 1) * next())
    }

    // Takes a value in percent [0; 100]
    // 100% could return false ( ͡° ͜ʖ ͡°)
    function chance(percent) {
        percent = math.clamp(percent, 0, 100)
        return next() < (percent / 100)
    }

    function nextElement(array) {
        if (!array || array.len() == 0) {
            throw "Array is empty or null"
        }
        return array[nextInt(0, array.len() - 1)]
    }
}

module <- LehmerRng