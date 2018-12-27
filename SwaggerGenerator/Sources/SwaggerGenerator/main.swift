import Foundation
import SwiftShell
import CommandLineKit

let filePath = StringOption(shortFlag: "f", longFlag: "file", required: false, helpMessage: "Swagger json url")
let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")
let cli = CommandLine()
cli.addOptions(filePath, help)

func parse(data: Data?, response: URLResponse?, error: Error?) {
    var code = EX_DATAERR
    defer { exit(code) }
    guard let data = data else {
        print("download failed: \(error.map(String.init(describing:)) ?? "no error provided")")
        return
    }
    print("download complete")
    do {
        let swagger = try JSONDecoder().decode(Swagger.self, from: data)
        let collector = Collector { print($0) }
        let api = swagger.object.parse(collector)
        print("parsing complete")


        code = EXIT_SUCCESS
    } catch {
        cli.printUsage(error)
        code = EX_NOINPUT
    }
}

do {
    try cli.parse()
    if help.value { cli.printUsage() }
    if let request = filePath.value.flatMap(URL.init(string:)).map({URLRequest(url: $0)}) {
        print("start download")
        URLSession.shared.dataTask(with: request, completionHandler: parse).resume()
    }
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

dispatchMain()
