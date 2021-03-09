typealias BechKeyOutput = (_ keyInfo: KeyInfo) throws -> KeyOutput

func printKeyInfo(keyInfo: KeyInfo, bechKeyOutput: BechKeyOutput, output: ClientOptions.OutputFormat) {
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

func printInfos(infos: [KeyInfo], output: ClientOptions.OutputFormat) {
    let keyOutputs = try! bech32KeysOutput(infos: infos)

    switch output {
    case .text:
        printTextInfos(keyOutputs: keyOutputs)

    case .json:
        // TODO: Implement
        fatalError()
//        var out []byte
//        var err error
//
//        if viper.GetBool(flags.FlagIndentResponse) {
//            out, err = KeysCdc.MarshalJSONIndent(kos, "", "  ")
//        } else {
//            out, err = KeysCdc.MarshalJSON(kos)
//        }
//
//        if err != nil {
//            panic(err)
//        }
//        fmt.Printf("%s", out)
    }
}

func printTextInfos(keyOutputs: [KeyOutput]) {
    print(keyOutputs)
    // TODO: Implement
//    let out = try yaml.marshal(&kos)
//    fmt.Println(string(out))
}

func printKeyAddress(info: KeyInfo, bechKeyOutput: BechKeyOutput) {
    let keyOutput = try! bechKeyOutput(info)
    print(keyOutput.address)
}
