unit Terminal4D;

{$REGION 'Copyright and license'}
/// ###########################################################################
/// ## Terminal.pas                                                          ##
/// ###########################################################################
/// ## Author: Maicon Pires                                                  ##
/// ## Company: SOiS - Soluções Integradas em Sistemas                       ##
/// ## Year: 2026                                                            ##
/// ##   ️                                                                   ##
/// ## Github: https://github.com/maiconpires                                ##
/// ## Youtube: https://www.youtube.com/@maiconserip                         ##
/// ##                                                                       ##
/// ## Utility library for terminal/console manipulation                     ##
/// ## Cross-platform (Windows / Linux) developed in Delphi.                 ##
/// ##                                                                       ##
/// ## Main Features:                                                        ##
/// ##  • Colored output (ANSI on Linux and native API on Windows)           ##
/// ##  • Automatic text alignment based on console window size              ##
/// ##  • Custom command registration and execution                          ##
/// ##  • Command-line parameter processing                                  ##
/// ##  • Dedicated thread for asynchronous input handling                   ##
/// ##                                                                       ##
/// ## --------------------------------------------------------------------- ##
/// ## MIT License                                                           ##
/// ## --------------------------------------------------------------------- ##
/// ## Copyright (c) 2026 Maicon Pires                                       ##
/// ##                                                                       ##
/// ## Permission is hereby granted, free of charge, to any person           ##
/// ## obtaining a copy of this software and associated documentation        ##
/// ## files (the "Software"), to deal in the Software without               ##
/// ## restriction, including without limitation the rights to use,          ##
/// ## copy, modify, merge, publish, distribute, sublicense, and/or sell     ##
/// ## copies of the Software, and to permit persons to whom the             ##
/// ## Software is furnished to do so, subject to the following              ##
/// ## conditions:                                                           ##
/// ##                                                                       ##
/// ## The above copyright notice and this permission notice shall be        ##
/// ## included in all copies or substantial portions of the Software.       ##
/// ##                                                                       ##
/// ## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       ##
/// ## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES       ##
/// ## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND              ##
/// ## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT           ##
/// ## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,          ##
/// ## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING          ##
/// ## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR         ##
/// ## OTHER DEALINGS IN THE SOFTWARE.                                       ##
/// ###########################################################################
{$ENDREGION}

interface

uses
{$IFDEF LINUX}
  Posix.Unistd,
  Posix.SysTypes,
  Posix.Termios,
  Posix.Stdlib,
  Posix.Dlfcn,
{$ELSE}
  Winapi.Windows,
{$ENDIF}
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.Threading,
  System.Generics.Collections,
  System.Diagnostics;

type
{$IFDEF LINUX}
  tcColor = (tcGray=90, tcRed, tcGreen, tcYellow, tcBlue, tcMagenta, tcCyan, tcWhite);

  TWinsize = record
      ws_row: Word;
      ws_col: Word;
      ws_xpixel: Word;
      ws_ypixel: Word;
    end;
{$ELSE}
  tcColor = (tcGray, tcBlue, tcGreen, tcCyan, tcRed, tcMagenta, tcYellow, tcWhite );
{$ENDIF}

  TTerminalTextAlign = class
    class function Left: Cardinal;
    class function Center: Cardinal;
    class function Right: Cardinal;
  end;

  TTerminal = class;
  TTerminalClass = class of TTerminal;

  TTerminalParam = record
    Execute: TProc<String>;
    Help: String;
  end;

  TTerminalCommand = record
    Execute: TProc<String>;
    Help: String;
  end;

  TTerminalParamList = TDictionary<String, TTerminalParam>;
  TTerminalCommandList = TDictionary<String, TTerminalCommand>;

  TTerminal = class(TInterfacedObject)
  private
    class var FInputThread: TThread;
    class var FInput: String;
    class var FCommands: TTerminalCommandList;
    class var FParams: TTerminalParamList;

    class var FLabel: String;

    class procedure WriteColor(AText: String; AColor: tcColor; ASpaces: Integer=0);
    class procedure WriteLNColor(AText: String; AColor: tcColor; ASpaces: Integer=0);
  public
    class var cx: Integer;

    class function &Label(const AValue: String): TTerminalClass;

    class function GetConsoleWidth: Integer;
    class function GetConsoleHeight: Integer;
    class procedure Beep(const AFrequence: Cardinal=1000; const ATime: Cardinal=300);

    class function Start: TTerminalClass;
    class function Stop: TTerminalClass;
    class function WaitFor: TTerminalClass;

    class function AddParams(const AParam: String; const ACallback: TProc<String>; const AHelpContext: String=''): TTerminalClass;
    class function GetParams: TTerminalParamList;
    class function ProcessParams: TTerminalClass;

    class function AddCommand(const ACommand: String; const ACallback: TProc<String>; const AHelpContext: String=''): TTerminalClass;
    class function GetCommands: TTerminalCommandList;

    class function WR(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;
    class function WRL(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;

    class function WR_L(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;
    class function WR_C(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;
    // não faz sentido uma vez que não dá para voltar e reescrever a linha antes de quebra-la
//    class function WR_R(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;

    class function WRL_L(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;
    class function WRL_C(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;
    class function WRL_R(AText: String; ASpaces: Integer=0; AColor: tcColor=tcWhite): TTerminalClass; overload;

    class function ParseCommandLine(const AInput: string): TArray<string>; overload;
    class function ParseCommandLine(const AInput: string; out ACommands: TArray<String>): TTerminalClass; overload;

  end;

{$REGION 'Como não temos (Posix.SysIoctl, Posix.ioctl, ioctl, SysIoctl) fazemos a moda antiga'}
{$IFDEF LINUX}
function ioctl(handle: Integer; request: Cardinal; argp: Pointer): Integer; cdecl;
  external 'libc.so.6' name 'ioctl';

  // Linux: 0x5413 (or 21523 in decimal)
const
  TIOCGWINSZ = 21523;
{$ENDIF}
{$ENDREGION}

implementation

{ TTerminal }

class function TTerminal.&Label(const AValue: String): TTerminalClass;
begin
  FLabel := AValue;
end;

class function TTerminal.AddCommand(const ACommand: String;
  const ACallback: TProc<String>; const AHelpContext: String=''): TTerminalClass;
var
  LCommand: TTerminalCommand;
begin
  Result := TTerminal;

  LCommand.Execute := ACallback;
  LCommand.Help    := AHelpContext;
  FCommands.AddOrSetValue(ACommand, LCommand);
end;

class function TTerminal.AddParams(const AParam: String; const ACallback: TProc<String>;
const AHelpContext: String): TTerminalClass;
var
  LParam: TTerminalParam;
begin
  Result := TTerminal;

  LParam.Execute := ACallback;
  LParam.Help    := AHelpContext;
  FParams.AddOrSetValue(AParam, LParam);
end;

class procedure TTerminal.Beep(const AFrequence, ATime: Cardinal);
begin
{$IFDEF LINUX}
  write(#7);
{$ELSE}
  Winapi.Windows.Beep(AFrequence, ATime);
{$ENDIF}
end;

class function TTerminal.GetCommands: TTerminalCommandList;
begin
  Result := FCommands;
end;

class function TTerminal.GetParams: TTerminalParamList;
begin
  Result := FParams;
end;

class function TTerminal.ParseCommandLine(const AInput: string): TArray<string>;
var
  I: Integer;
  InQuotes: Boolean;
  EscapeNext: Boolean;
  Current: string;
  C: Char;
  List: TList<string>;
begin
  List := TList<string>.Create;
  try
    InQuotes := False;
    EscapeNext := False;
    Current := '';

    for I := 1 to Length(AInput) do
    begin
      C := AInput[I];

      if EscapeNext then
      begin
        Current := Current + C;
        EscapeNext := False;
        Continue;
      end;

      case C of
        '\':
          begin
            EscapeNext := True;
          end;
        '"':
          begin
            if not EscapeNext then
              InQuotes := not InQuotes
            else
              Current := Current + C;
          end;
        ' ':
          begin
            if InQuotes then
              Current := Current + C
            else
            begin
              if Current <> '' then
              begin
                List.Add(Current);
                Current := '';
              end;
            end;
          end;
      else
        Current := Current + C;
      end;
    end;

    if EscapeNext then
      Current := Current + '\';

    if Current <> '' then
      List.Add(Current);

    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

class function TTerminal.ParseCommandLine(const AInput: string; out ACommands: TArray<String>): TTerminalClass;
begin
  Result := TTerminal;

  ACommands := ParseCommandLine(AInput);
end;

class function TTerminal.ProcessParams: TTerminalClass;
var
  I: Integer;
  Param: TTerminalParam;
  Value: String;
begin
  Result := TTerminal;

  for I := 1 to ParamCount do begin
    if FParams.ContainsKey(ParamStr(I)) then begin
      Param := FParams.Items[ParamStr(I)];
      Value := ParamStr(I+1);
      Param.Execute(Value);
    end;
  end;
end;

class function TTerminal.Start: TTerminalClass;
begin
  Result := TTerminal;
  FInputThread.Start;
end;

class function TTerminal.Stop: TTerminalClass;
begin
  Result := TTerminal;

  if Assigned(FInputThread) then begin
    FInputThread.Terminate;
  end;
end;

class function TTerminal.WaitFor: TTerminalClass;
begin
  Result := TTerminal;

  if FInputThread <> nil then begin
    FInputThread.WaitFor;
  end;
end;

{$REGION 'Console Window'}
{$IFDEF LINUX}
class function TTerminal.GetConsoleHeight: Integer;
var
  ws: TWinsize;
begin
  if ioctl(STDOUT_FILENO, TIOCGWINSZ, @ws) = 0 then
    Result := ws.ws_row
  else
    Result := 0;
end;

class function TTerminal.GetConsoleWidth: Integer;
var
  ws: TWinsize;
begin
  if ioctl(STDOUT_FILENO, TIOCGWINSZ, @ws) = 0 then
    Result := ws.ws_col
  else
    Result := 0;
end;

{$ELSE}
class function TTerminal.GetConsoleWidth: Integer;
var
  BufInfo: TConsoleScreenBufferInfo;
  Console: THandle;
begin
  Console := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(Console, BufInfo) then
    Result := BufInfo.srWindow.Right - BufInfo.srWindow.Left + 1
  else
    Result := 0;
end;

class function TTerminal.GetConsoleHeight: Integer;
var
  BufInfo: TConsoleScreenBufferInfo;
  Console: THandle;
begin
  Console := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(Console, BufInfo) then
    Result := BufInfo.srWindow.Bottom - BufInfo.srWindow.Top + 1
  else
    Result := 0;
end;

{$ENDIF}
{$ENDREGION}

{$REGION 'System COUT'}
{$IFDEF LINUX}
class procedure TTerminal.WriteColor(AText: String; AColor: tcColor; ASpaces: Integer=0);
begin
  System.Write(Format('%s[%dm%s[%dC%s',[#27,Ord(AColor), #27, ASpaces, AText]));
  cx := cx+ASpaces+Length(AText);
end;

class procedure TTerminal.WriteLNColor(AText: String; AColor: tcColor; ASpaces: Integer);
begin
  System.WriteLN(Format('%s[%dm%s[%dC%s',[#27,Ord(AColor), #27, ASpaces, AText]));
  cx := 0;
end;

class function TTerminal.WR_L(AText: String; ASpaces: Integer;   AColor: tcColor): TTerminalClass;
begin
  WriteColor(AText, AColor, TTerminalTextAlign.Left + ASpaces - cx-1);
end;

class function TTerminal.WR_C(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteColor(AText, AColor, TTerminalTextAlign.Center+ASpaces-Trunc(Length(AText)/2)-cx-1);
end;

class function TTerminal.WRL_L(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, TTerminalTextAlign.Left + ASpaces - cx-1);
end;

class function TTerminal.WRL_C(AText: String; ASpaces: Integer; AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, TTerminalTextAlign.Center+ASpaces-Trunc(Length(AText)/2)-cx-1);
end;

class function TTerminal.WRL_R(AText: String; ASpaces: Integer; AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, TTerminalTextAlign.Right-ASpaces-Trunc(Length(AText))-cx-1);
end;

{$ELSE}
class procedure TTerminal.WriteColor(AText: String; AColor: tcColor; ASpaces: Integer=0);
var
  Console: THandle;
  BufInfo: TConsoleScreenBufferInfo;
begin
  Console := TTextRec(Output).Handle;
  GetConsoleScreenBufferInfo(Console, BufInfo);
  SetConsoleTextAttribute(Console, FOREGROUND_INTENSITY or Word(AColor));
    System.Write( AText: ASpaces );
  SetConsoleTextAttribute(Console, BufInfo.wAttributes);
  Inc(cx, ASpaces);
end;

class procedure TTerminal.WriteLNColor(AText: String; AColor: tcColor; ASpaces: Integer);
var
  Console: THandle;
  BufInfo: TConsoleScreenBufferInfo;
begin
  Console := TTextRec(Output).Handle;
  GetConsoleScreenBufferInfo(Console, BufInfo);
  SetConsoleTextAttribute(Console, FOREGROUND_INTENSITY or Word(AColor));
    System.WriteLN( AText: ASpaces );
  SetConsoleTextAttribute(Console, BufInfo.wAttributes);
  cx := 0;
end;

class function TTerminal.WR_L(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteColor(AText, AColor, Length(AText)+TTerminalTextAlign.Left+ASpaces - cx);
end;

class function TTerminal.WR_C(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteColor(AText, AColor, Trunc(Length(AText)/2)+TTerminalTextAlign.Center+ASpaces - trunc(cx));
end;

class function TTerminal.WRL_L(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, Length(AText)+TTerminalTextAlign.Left+ASpaces - cx);
end;

class function TTerminal.WRL_C(AText: String; ASpaces: Integer; AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, Trunc(Length(AText)/2)+TTerminalTextAlign.Center+ASpaces - trunc(cx));
end;

class function TTerminal.WRL_R(AText: String; ASpaces: Integer; AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, TTerminalTextAlign.Right-ASpaces-cx);
end;

{$ENDIF}

class function TTerminal.WR(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteColor(AText, AColor, ASpaces);
end;

class function TTerminal.WRL(AText: String; ASpaces: Integer;
  AColor: tcColor): TTerminalClass;
begin
  WriteLNColor(AText, AColor, ASpaces);
end;

{$ENDREGION}

{ TTerminalTextAlign }

class function TTerminalTextAlign.Center: Cardinal;
begin
  Result := Trunc(TTerminal.GetConsoleWidth/2);
end;

class function TTerminalTextAlign.Left: Cardinal;
begin
  Result := 0;
end;

class function TTerminalTextAlign.Right: Cardinal;
begin
  Result := TTerminal.GetConsoleWidth;
end;

initialization
  TTerminal.cx := 1;
  TTerminal.FLabel := 'SOiS Terminal';
  TTerminal.FParams := TTerminalParamList.Create;
  TTerminal.FCommands := TTerminalCommandList.Create;

  TTerminal.FInputThread := TThread.CreateAnonymousThread(procedure
  var
    LCommand:  TTerminalCommand;
    LInput: TArray<String>;
  begin
    while not TThread.CurrentThread.CheckTerminated do begin
      TTerminal.WR(TTerminal.FLabel+'> ');
      TTerminal.cx := 0;
      Readln(TTerminal.FInput);

//      LInput := TTerminal.FInput.Split([' ']);
      LInput := TTerminal.ParseCommandLine(TTerminal.FInput);
      if Length(LInput) = 0 then continue;

      if TTerminal.FCommands.TryGetValue(LInput[0], LCommand) then
        try
          LCommand.Execute(TTerminal.FInput)
        except
        end
      else
        TTerminal.WRL('Unknown command', 0, tcRed);
    end;
  end);
  TTerminal.FInputThread.FreeOnTerminate := False;

finalization
  if Assigned(TTerminal.FParams) then
    FreeAndNil(TTerminal.FParams);

  if Assigned(TTerminal.FCommands) then
    FreeAndNil(TTerminal.FCommands);

  FreeAndNil(TTerminal.FInputThread); // ??? aqui
end.
