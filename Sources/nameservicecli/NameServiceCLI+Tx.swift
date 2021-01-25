//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 22/01/2021.
//

import Foundation







/*
 
 
 func txCmd(cdc *amino.Codec) *cobra.Command {
     txCmd := &cobra.Command{
         Use:   "tx",
         Short: "Transactions subcommands",
     }

     txCmd.AddCommand(
         bankcmd.SendTxCmd(cdc),
         flags.LineBreak,
         authcmd.GetSignCommand(cdc),
         authcmd.GetMultiSignCommand(cdc),
         flags.LineBreak,
         authcmd.GetBroadcastCommand(cdc),
         authcmd.GetEncodeCommand(cdc),
         authcmd.GetDecodeCommand(cdc),
         flags.LineBreak,
     )

     // add modules' tx commands
     app.ModuleBasics.AddTxCommands(txCmd, cdc)

     // remove auth and bank commands as they're mounted under the root tx command
     var cmdsToRemove []*cobra.Command

     for _, cmd := range txCmd.Commands() {
         if cmd.Use == auth.ModuleName || cmd.Use == bank.ModuleName {
             cmdsToRemove = append(cmdsToRemove, cmd)
         }
     }

     txCmd.RemoveCommand(cmdsToRemove...)

     return txCmd
 }
 
 */
