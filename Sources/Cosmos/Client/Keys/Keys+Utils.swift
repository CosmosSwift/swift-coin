typealias BechKeyOutput = (_ keyInfo: Info) throws -> KeyOutput

func printKeyInfo(keyInfo: Info, bechKeyOutput: BechKeyOutput, output: ClientOptions.OutputFormat) {
    let keyOutput = try! bechKeyOutput(keyInfo)

    switch output {
    case .text:
        printTextInfos(keyOutputs: [keyOutput])

    case .json:
        // TODO: Implement
        fatalError()
//        var out []byte
//        var err error
//        if viper.GetBool(flags.FlagIndentResponse) {
//            out, err = KeysCdc.MarshalJSONIndent(ko, "", "  ")
//        } else {
//            out, err = KeysCdc.MarshalJSON(ko)
//        }
//        if err != nil {
//            panic(err)
//        }
//
//        fmt.Println(string(out))
    }
}

func printTextInfos(keyOutputs: [KeyOutput]) {
    print(keyOutputs)
    // TODO: Implement
//    let out = try yaml.marshal(&kos)
//    fmt.Println(string(out))
}

