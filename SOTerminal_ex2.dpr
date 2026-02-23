program SOTerminal_ex2;

/// ############################################################################
/// ## SOTerminal_ex2                                                         ##
/// ############################################################################
/// ## Console application example using the TSOTerminal infrastructure.      ##
/// ##                                                                        ##
/// ## This example demonstrates:                                             ##
/// ##  - Creation and configuration of custom parameters                     ##
/// ##  - Registration of terminal commands                                   ##
/// ##  - Initialization and execution of the main loop                       ##
/// ##  - Writing colored messages to the console                             ##
/// ##                                                                        ##
/// ## Execution flow:                                                        ##
/// ##  1) CreateParams    -> Defines supported parameters (-nc, -no, etc.)   ##
/// ##  2) CreateCommands  -> Registers available commands                    ##
/// ##  3) Initialize      -> Prepares the terminal environment               ##
/// ##  4) Start           -> Starts processing                               ##
/// ##  5) WaitFor         -> Waits for termination                           ##
/// ##                                                                        ##
/// ## To test execution parameters:                                          ##
/// ##  - Go to: Run -> Parameters -> Parameters                              ##
/// ##  - Provide values such as: -nc or -no                                  ##
/// ##                                                                        ##
/// ## When finished, a red message will be displayed asking to press ENTER.  ##
/// ############################################################################

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SOTerminal in 'src\ex2\SOTerminal.pas',
  Terminal4D in 'lib\Terminal4D.pas';

begin
  TSOTerminal
    .CreateParams
    .CreateCommands
    .Initialize
    .Start
    .WaitFor
    .WRL('TERMINATED! Press ENTER to close.', 0, tcRed);

    readln;
end.
