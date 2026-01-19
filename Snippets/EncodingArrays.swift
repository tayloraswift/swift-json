import JSON

let json: JSON = .array {
    for i: Int in 0 ... 3 {
        $0[+] = [_].init(0 ... i)
    }
}

print(json)
