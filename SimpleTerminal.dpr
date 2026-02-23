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
    .Start
    .WaitFor
    .WRL('TERMINATED! Press ENTER to close.', 0, tcRed);

    TTerminal.Beep;
    readln;

end.
