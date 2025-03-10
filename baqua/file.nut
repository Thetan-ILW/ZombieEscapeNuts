local filename_format = "c%i_%s"

class File {
    function read(filename) {
        if (filename == null) {
            error("File name is null")
        }

        local string = ""
        local filedata = null
        local chunk = 0
        while (filedata = FileToString(format(filename_format, chunk, filename))) {
            string += filedata
            chunk += 1
        }

        return string
    }

    function write(filename, string) {
        if (filename == null) {
            error("File name is null")
        }

        // -1 because the game appends the null at the end of the file
        // 16384 bytes is the max the game can read
        local chunk_size = 16384.0 - 1.0
        local chunks = (string.len() / chunk_size)

        for (local i = 0; i < chunks; i++) {
            local start = i * chunk_size
            local end = (i + 1) * chunk_size

            if (end > string.len()) {
                end = string.len()
            }

            StringToFile(format(filename_format, i, filename), string.slice(start, end))
        }
    }
}

module <- File