program SimpleTerminal;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections,
  Terminal4D in 'lib\Terminal4D.pas';

begin
  TTerminal
    .Label('Simple Terminal')
    .WRL('')
    .WRL_C('A Simple sample of a Windows and Linux Terminal', 0, tcBlue)
    .WRL('')
    .WRL('Type "help" for help')
    .AddParams('-name',
      procedure (AParam:String) begin
        TTerminal
          .WRL('')
          .WRL('Welcome '+AParam, 5)
          .WRL('');
      end,
      'A Welcome message')
    .ProcessParams
    .AddCommand('help',
      procedure (ACommand: String)
      var
        I: Integer;
        Keys: TArray<String>;
        Key: String;
      begin
        Keys := TTerminal.GetCommands.Keys.ToArray;
        TArray.Sort<String>(Keys);

        TTerminal.WRL('')
          .WRL_C('########## A CUSTOM TERMINAL - LIST OF ALL COMMANDS ##########', 0, tcBlue)
          .WRL('')
          .WR_L('Command')
          .WRL_L('Description', 10);
        for Key in Keys do begin
          TTerminal.WR_L(Key, 2, tcWhite)
            .WRL_L(TTerminal.GetCommands.Items[Key].Help, 15 - Length(Key), tcGray);
        end;

      end,
      'This help message')
    .AddCommand('sum',
      procedure (ACommand: String)
      var
        LCommand: TArray<String>;
        n1, n2: Real;
        C: String;
      begin
        LCommand := ACommand.Split([' ']);
        n1 := LCommand[1].ToDouble;
        n2 := LCommand[2].ToDouble;
        TTerminal
          .WR(' > ')
          .WR(FloatToStr(n1), 0, tcGreen)
          .WR(' + ', 0, tcBlue)
          .WR(FloatToStr(n2), 0, tcGreen)
          .WR(' = ', 0, tcBlue)
          .WRL(FloatToStr(n1 + n2), 0, tcGreen)
      end,
      'Sum two number. Ex.: sum 2 3')
    .AddCommand('exit',
      procedure (ACommand: String)
      begin
        TTerminal.Stop;
      end,
      'Halt terminal')
    .AddCommand('align',
      procedure (ACommand: String)
      begin
        TTerminal
          .WRL('')
          .WR_L('L123456789', 0)
          .WRL_L('TABX', 15)
          .WR_L('L123456', 0)
          .WRL_L('TABX', 15)
          .WR_L('L123', 0)
          .WRL_L('TABX', 15)
          .WR_C('C123456789', 0)
          .WRL_C('T', 12)
          .WR_C('C123456', 0)
          .WRL_C('T123', 12)
          .WR_C('C123', 0)
          .WRL_C('T123456',12)
          .WRL_R('R123456789', 0)
          .WRL_R('R123456', 1)
          .WRL_R('R123', 2)
          .WR_L('L123456789', 0)
          .WR_L('TABX:', 15)
          .WR_C('C123', 0)
          .WRL_R('R123456789', 0)

      end,
      'Text align test')
    .AddCommand('command',
      procedure (ACommand: String)
      var
        I: Integer;
        Input: string;
        Command: TArray<string>;
      begin
        TTerminal
          .WR_L('Command test. Try sintaxes like: ')
          .WRL_L('cmd -param1 simplevalue -param2 "composite value like this" -param3 simplevalue2',0, tcGray);

        TTerminal.WR('Enter command: ');
        readln(Input);

        TTerminal.ParseCommandLine(Input, Command);
        for I := 0 to Length(Command)-1 do begin
          TTerminal.WRL_L(Command[I], 5, tcGray);
        end;
      end,
      'Text align test')
    .Start
    .WaitFor
    .WRL('TERMINATED! Press ENTER to close.', 0, tcRed);

    TTerminal.Beep;
    readln;

end.
