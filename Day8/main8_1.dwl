%dw 2.0
output application/json

type Entry = {
    uniqueSignalPatterns: Array<String>,
    digitOutputValue: Array<String>
}

var signals = (payload splitBy "\n") map do {
    var splitted = $ splitBy "|"
    ---
    {
        uniqueSignalPatterns: splitted[0] splitBy  " " filter $ != "",
        digitOutputValue: splitted[1] splitBy " " filter $ != ""
    }
}

var known = [2, 4, 3 ,7]


---
signals reduce ((entry, instances = 0) -> instances + sizeOf(entry.digitOutputValue filter (known contains sizeOf($))))