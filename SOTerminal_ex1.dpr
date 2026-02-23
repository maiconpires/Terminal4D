program SOTerminal_ex1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections,
  Terminal4D in 'lib\Terminal4D.pas';

var
  NumberColor: Integer;
  OperatorColor: Integer;

begin
  NumberColor := ord(tcGreen);
  OPeratorColor := ord(tcBlue);

  TTerminal
    .AddParams(
      '-nc',
      procedure (AParam: String)
      begin
        NumberColor := AParam.ToInteger;
      end,
      'Define the number''s color in the operation')
    .AddParams(
      '-no',
      procedure (AParam: String)
      begin
        OperatorColor := AParam.ToInteger;
      end,
      'Defines the operator''s color in the operation')
    .ProcessParams  // necessary to process the parameters entered in the console
    .WRL('')
    .WRL_C('A Simple sample of a Windows and Linux Terminal', 0, tcBlue)
    .WRL('')
    .WRL('Type "help" for help')
    .&Label('SOiS Terminal')
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
    .AddCommand('exit',
      procedure (ACommand: String)
      begin
        TTerminal.Stop;
      end,
      'Halt terminal')
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
          .WR(FloatToStr(n1), 0, tcColor(NumberColor))
          .WR(' + ', 0, tcColor(OperatorColor))
          .WR(FloatToStr(n2), 0, tcColor(NumberColor))
          .WR(' = ', 0, tcColor(OperatorColor))
          .WRL(FloatToStr(n1 + n2), 0, tcColor(NumberColor))
      end,
      'Sum two number. Ex.: sum 2 3')
    .AddCommand('sub',
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
          .WR(FloatToStr(n1), 0, tcColor(NumberColor))
          .WR(' - ', 0, tcColor(OperatorColor))
          .WR(FloatToStr(n2), 0, tcColor(NumberColor))
          .WR(' = ', 0, tcColor(OperatorColor))
          .WRL(FloatToStr(n1 - n2), 0, tcColor(NumberColor))
      end,
      'Subtract two number. Ex.: sub 2 3')
    .AddCommand('mul',
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
          .WR(FloatToStr(n1), 0, tcColor(NumberColor))
          .WR(' * ', 0, tcColor(OperatorColor))
          .WR(FloatToStr(n2), 0, tcColor(NumberColor))
          .WR(' = ', 0, tcColor(OperatorColor))
          .WRL(FloatToStr(n1 * n2), 0, tcColor(NumberColor))
      end,
      'Multiply two number. Ex.: mul 2 3')
    .AddCommand('div',
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
          .WR(FloatToStr(n1), 0, tcColor(NumberColor))
          .WR(' / ', 0, tcColor(OperatorColor))
          .WR(FloatToStr(n2), 0, tcColor(NumberColor))
          .WR(' = ', 0, tcColor(OperatorColor))
          .WRL(FloatToStr(n1 / n2), 0, tcColor(NumberColor))
      end,
      'Divide two number. Ex.: div 2 3')
    .AddCommand('beep',
      procedure (ACommand: String)
      begin
        TTerminal.Beep;
      end,
      'Do a beep')
    .Start
    .WaitFor
    .WRL('TERMINATED! Press ENTER to close.', 0, tcRed);

    readln;
end.
