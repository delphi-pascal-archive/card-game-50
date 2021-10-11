unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Menus, IniFiles, ShellApi;

const
  gmMatrixCardsX           = 15;
  gmMatrixCardsY           = 17;

  gmMaxCards               = 6;

  gmMaxCardsX              = 8;
  gmMaxCardsY              = 3;

  gmCardsWidth             = 71;
  gmCardsHeight            = 96;

  gmDistanceCardsX         = 5;
  gmDistanceCardsY         = 5;

  gmMaxShirts              = 10;

  gmMaxPackCards           = 3;
  gmPackCardsX             = 45;
  gmPackCardsY             = 100;

  gmTatgetComputerX        = 38;
  gmTatgetComputerY        = 100;
  
  gmTargetUserY            = 100;

  gmEndGame                = 50;

  gmPlayersBothPointsTextY = 265;
  gmCourseTextY            = 83;

var
  gmMoveCardXY: Integer;
  gmMoveStartGameCardXY: Integer;
  gmMoveStopGameCardXY: Integer;
  gmMovePackCardXY: Integer;
  gmMoveComputerCardXY: Integer;
  gmMoveCardsSleep: Integer;
  gmComputerSleep: Integer;

type
  TGameShirts = array [0..gmMaxShirts - 1] of TBitmap;

  TGameCard = record
    gcChervi, gcPiki, gcTrefi, gcBubni: TBitmap;
  end;

  TGameCards = array [0..gmMaxCards - 1] of TGameCard;

  TResourceManager = class
    BackGround: TBitmap;
    BackGroundCard: TBitmap;
    GameShirts: TGameShirts;
    GameCards: TGameCards;
    TargetUser: TBitmap;
    TargetComputer: TBitmap;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TCustomCard = class(TGraphicControl)
    Theme: TBitmap;
    procedure Move(X, Y: Integer; Step: Integer);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TMoveCard = class(TCustomCard)
  private
    FStartCurPos: TPoint;
    FStartPos: TPoint;
    FDrag: Boolean;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    Number: Integer;
  end;

  TMoveCards = array [0..gmMaxCardsX - 1, 0..gmMaxCardsY - 1] of TMoveCard;

  TTargetCard = class(TCustomCard)
  public
    Number: Integer;
  end;

  TTargetList = class(TList)
  private
    function GetItems(I: Integer): TTargetCard;
  public
    function Add: TTargetCard;
    procedure Clear; override;
    property Items[I: Integer]: TTargetCard read GetItems;
  end;

  TPackCard = class(TCustomCard)
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

  TPackCards = array [0..gmMaxPackCards - 1] of TPackCard;

  TMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    procedure N8Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Exception(Sender: TObject; E: Exception);
    procedure N7Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    procedure CardsUserDragDrop(Dest: TMoveCard; crPos: TPoint; mxPos: TPoint);
    procedure CardsComputerDragDrop(Dest: TMoveCard; mxPos: TPoint);
    procedure PackCardsClick(Sender: TPackCard);
  public
    PlayersBothPoints: Integer;
    PackCards: TPackCards;
    TargetComputer: TTargetCard;
    TargetUser: TTargetCard;
    MoveCards: TMoveCards;
    CardsDrag: Boolean;
    GameStarted: Boolean;
    GameExit: Boolean;
    PlayersBothPointsText: string;
    CourseText: string;
    TargetComputerList: TTargetList;
    TargetUserList: TTargetList;
    procedure StartGame;
    procedure StopGame;
    function EndGame(Computer: Boolean): Boolean;
    function MsgBox(Text: string): Boolean;
    function GetNumberCard: Integer;
    function GetColourCard(N: Integer): TBitmap;
    procedure Computer;
    function GetTargetUserPoint(X, Y: Integer): Boolean;
    function GetUserCardXY: TPoint;
    procedure NextCard(Dest: TMoveCard; mxPos: TPoint);
    function GetComputerCardXY: TPoint;
    function GetComputerCard: TMoveCard;
    function GetCardNumber(N: Integer): TMoveCard;
  end;

var
  ResourceManager: TResourceManager;
  Configuration: TIniFile;
  Main: TMain;

const
  gmIniMoveCardsSleep = 'MoveCardsSleep';
  gmIniMoveCardXY = 'MoveCardXY';
  gmIniMoveStartGameCardXY = 'MoveStartGameCardXY';
  gmIniMoveStopGameCardXY = 'MoveStopGameCardXY';
  gmIniMovePackCardXY = 'MovePackCardXY';
  gmIniMoveComputerCardXY = 'MoveComputerCardXY';
  gmIniComputerSleep = 'ComputerSleep';
  gmIniShirtIndex = 'ShirtIndex';
  gmIniBeginFirstUser = 'BeginFirstUser';
  gmIniColourCards = 'ColourCards';
  gmIniNextCard = 'NextCard';
  gmIniMainInfo = 'MainInfo';

const
  gmCongratVictoryText = 'Вы выйграли! Сыграем еще?';
  gmCongratLossText = 'Вы проиграли! Сыграем еще?';
  gmCourseUserText = 'Ход: пользователь';
  gmCourseComputerText = 'Ход: компьютер';
  gmPlayersBothPointsText = 'Сумма карт взятых обеими партнерами';

implementation

uses Unit3, Unit2;

{$R Images.res}
{$R *.dfm}

procedure TMain.N8Click(Sender: TObject);
begin
  About := TAbout.Create(Application);
  About.ShowModal;
  About.Free;
end;

{ TResourceManager }

constructor TResourceManager.Create;
var
  I: Integer;
  N: string;
begin
  BackGround := TBitmap.Create;
  BackGround.LoadFromResourceName(hinstance, 'BG_MAIN');
  BackGroundCard := TBitmap.Create;
  BackGroundCard.LoadFromResourceName(hinstance, 'BG_CARD');
  BackGroundCard.Transparent := true;
  for I := 0 to gmMaxShirts - 1 do
  begin
    GameShirts[I] := TBitmap.Create;
    GameShirts[I].LoadFromResourceName(hinstance, 'SHIRT_' + Inttostr(I + 1));
    GameShirts[I].Transparent := true;
  end;
  for I := 0 to gmMaxCards - 1 do
  begin
    N := Inttostr(I + 1);
    GameCards[I].gcChervi := TBitmap.Create;
    GameCards[I].gcChervi.LoadFromResourceName(hinstance, 'CARD_CHERVI_' + N);
    GameCards[I].gcChervi.Transparent := true;
    GameCards[I].gcPiki := TBitmap.Create;
    GameCards[I].gcPiki.LoadFromResourceName(hinstance, 'CARD_PIKI_' + N);
    GameCards[I].gcPiki.Transparent := true;
    GameCards[I].gcTrefi := TBitmap.Create;
    GameCards[I].gcTrefi.LoadFromResourceName(hinstance, 'CARD_TREFI_' + N);
    GameCards[I].gcTrefi.Transparent := true;
    GameCards[I].gcBubni := TBitmap.Create;
    GameCards[I].gcBubni.LoadFromResourceName(hinstance, 'CARD_BUBNI_' + N);
    GameCards[I].gcBubni.Transparent := true;
  end;
  TargetUser := TBitmap.Create;
  TargetUser.LoadFromResourceName(hinstance, 'TARGET_USER');
  TargetUser.Transparent := true;
  TargetComputer := TBitmap.Create;
  TargetComputer.LoadFromResourceName(hinstance, 'TARGET_COMPUTER');
  TargetComputer.Transparent := true;
end;

destructor TResourceManager.Destroy;
var
  I: Integer;
begin
  TargetComputer.Free;
  TargetUser.Free;
  for I := 0 to gmMaxCards - 1 do
  begin
    GameCards[I].gcBubni.Free;
    GameCards[I].gcTrefi.Free;
    GameCards[I].gcPiki.Free;
    GameCards[I].gcChervi.Free;
  end;
  for I := 0 to gmMaxShirts - 1 do
    GameShirts[I].Free;
  BackGroundCard.Free;
  BackGround.Free;
end;

procedure TMain.FormPaint(Sender: TObject);
var
  Xc, Yc, Xn, Yn: Integer;
  I, J: Integer;
begin

  with ResourceManager do
  begin
    Xc := (Width div Background.Width) + Background.Width;
    Yc := (Height div Background.Height) + Background.Height;
    Xn := 0;
    Yn := 0;
    for I := 0 to Xc - 1 do
    begin
      for J := 0 to Yc - 1 do
      begin
        Canvas.Draw(Xn, Yn, BackGround);
        Yn := Yn + Background.Height;
      end;
      Yn := 0;
      Xn := Xn + Background.Width;
    end;

    Xn := gmMatrixCardsX;
    Yn := gmMatrixCardsY;

    for I := 0 to gmMaxCardsX - 1 do
    begin
      for J := 0 to gmMaxCardsY - 1 do
      begin
        Canvas.Draw(Xn, Yn, BackGroundCard);
        Yn := Yn + gmCardsHeight + gmDistanceCardsY;
      end;
      Yn := gmMatrixCardsY;
      Xn := Xn + gmCardsWidth + gmDistanceCardsX;
    end;
  end;

  with Canvas do
  begin
    Brush.Style := bsClear;
    Font.Style := [fsBold];
    Font.Size := 18;
    TextOut(Round((Width - TextWidth(PlayersBothPointsText)) / 2),
      Height - gmPlayersBothPointsTextY, PlayersBothPointsText);
    Font.Size := 10;
    TextOut(Round((Width - TextWidth(CourseText)) / 2), Height - gmCourseTextY,
      CourseText);
  end;

end;

procedure TMain.FormCreate(Sender: TObject);
var
  I, J: Integer;
begin

  Application.Title := Caption;
  Application.OnException := Exception;
  
  DoubleBuffered := true;
  CardsDrag := true;

  for I := 0 to gmMaxPackCards - 1 do
  begin
    PackCards[I] := TPackCard.Create(Self);
    PackCards[I].Theme := ResourceManager.GameShirts[Configuration.ReadInteger(gmIniMainInfo, gmIniShirtIndex, 0)];
    PackCards[I].Left := Width - PackCards[I].Width + (I * 2) - gmPackCardsX;
    PackCards[I].Top := Height - PackCards[I].Height + (I * 2) - gmPackCardsY;
    PackCards[I].Parent := Self;
  end;

  TargetComputer := TTargetCard.Create(Self);
  TargetComputer.Theme := ResourceManager.TargetComputer;
  TargetComputer.Left := gmTatgetComputerX;
  TargetComputer.Top := Height - TargetComputer.Height - gmTatgetComputerY;
  TargetComputer.Parent := Self;

  TargetUser := TTargetCard.Create(Self);
  TargetUser.Theme := ResourceManager.TargetUser;
  TargetUser.Left := Round((Width - TargetUser.Width) / 2);
  TargetUser.Top := Height - TargetUser.Height - gmTargetUserY;
  TargetUser.Parent := Self;

  for I := 0 to gmMaxCardsX - 1 do
  begin
    for J := 0 to gmMaxCardsY - 1 do
    begin
      MoveCards[I, J] := TMoveCard.Create(Self);
      MoveCards[I, J].Left := PackCards[gmMaxPackCards - 1].Left;
      MoveCards[I, J].Top := PackCards[gmMaxPackCards - 1].Top;
      MoveCards[I, J].Parent := Self;
      MoveCards[I, J].Hide;
    end;
  end;

  TargetComputerList := TTargetList.Create;
  TargetUserList := TTargetList.Create;

  Randomize;

end;

procedure TMain.N5Click(Sender: TObject);
begin
  Option := TOption.Create(Application);
  Option.ShowModal;
  Option.Free;
end;

{ TCustomCard }

constructor TCustomCard.Create(AOwner: TComponent);
begin
  inherited;
  SetBounds(Left, Top, gmCardsWidth, gmCardsHeight);
end;

procedure TCustomCard.Move(X, Y, Step: Integer);
var
  I: Integer;
begin

  while (Left <> X) or (Top <> Y) do
  begin

    if Top > Y then
    begin
      if Top - Step > Y then
        Top := Top - Step
      else
        Top := Y;
    end
    else
    begin
      if Top + Step < Y then
        Top := Top + Step
      else
        Top := Y;
    end;

    if Left > X then
    begin
        if Left - Step > X then
          Left := Left - Step
        else
          Left := X;
    end
    else
    begin
      if Left + Step < X then
        Left := Left + Step
      else
        Left := X;
    end;

    for I := 0 to gmMoveCardsSleep - 1 do
      Application.ProcessMessages;

  end;
end;

procedure TCustomCard.Paint;
begin
  Canvas.StretchDraw(Rect(0, 0, Width, Height), Theme);
end;

{ TMoveCard }

procedure TMoveCard.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  Inherited;
  if (Button = mbLeft) and Main.CardsDrag then
  begin
    BringToFront;
    FStartCurPos := Point(X, Y);
    FStartPos := Point(Left, Top);
    FDrag := true;
  end;
end;

procedure TMoveCard.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  Inherited;
  if FDrag then
  begin
    Left := Left - (FStartCurPos.X - X);
    Top := Top - (FStartCurPos.Y - Y);
    Application.ProcessMessages;
  end;
end;

procedure TMoveCard.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  Inherited;
  if FDrag then
  begin
    FDrag := false;
    Main.CardsUserDragDrop(Self, Main.ScreenToClient(ClientToScreen(Point(X, Y))), FStartPos);
  end;
end;

procedure TMain.CardsUserDragDrop(Dest: TMoveCard; crPos, mxPos: TPoint);
var
  Pos: TPoint;
begin
  if GetTargetUserPoint(crPos.X, crPos.Y) then
  begin
    Dest.Hide;
    Pos := GetUserCardXY;
    with TargetUserList.Add do
    begin
      Left := Dest.Left;
      Top := Dest.Top;
      Theme := Dest.Theme;
      Number := Dest.Number;
      Parent := Self;
      Move(Pos.X, Pos.Y, gmMoveCardXY);
    end;
    PlayersBothPoints := PlayersBothPoints + Dest.Number;
    PlayersBothPointsText := gmPlayersBothPointsText + ' ' + InttoStr(PlayersBothPoints);
    Invalidate;
    if EndGame(false) then Exit;
    NextCard(Dest, mxPos);
    CourseText := gmCourseComputerText;
    Invalidate;
    Computer;
  end
  else
    Dest.Move(mxPos.X, mxPos.Y, gmMoveCardXY);
end;

{ TPackCard }

procedure TPackCard.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if Button = mbLeft then Main.PackCardsClick(Self);
end;

procedure TMain.PackCardsClick(Sender: TPackCard);
begin
  N3.Click;
end;

procedure TMain.FormDestroy(Sender: TObject);
var
  I, J: Integer;
begin
  TargetUserList.Free;
  TargetComputerList.Free;
  for I := 0 to gmMaxCardsX - 1 do
    for J := 0 to gmMaxCardsY - 1 do
       MoveCards[I, J].Free;
  TargetUser.Free;
  TargetComputer.Free;
  for I := 0 to gmMaxPackCards - 1 do
    PackCards[I].Free;
end;

function TMain.EndGame(Computer: Boolean): Boolean;
begin
  Result := false;
  
  if Computer then
  begin
    if PlayersBothPoints = gmEndGame then
    begin
      if MsgBox(gmCongratLossText) then
      begin
        StopGame;
        StartGame;
      end
      else
        StopGame;
      Result := true;
    end
    else
    if PlayersBothPoints > gmEndGame then
    begin
      if MsgBox(gmCongratVictoryText) then
      begin
        StopGame;
        StartGame;
      end
      else
        StopGame;
      Result := true;
    end;
  end
  else
  begin
    if PlayersBothPoints = gmEndGame then
    begin
      if MsgBox(gmCongratVictoryText) then
      begin
        StopGame;
        StartGame;
      end
      else
        StopGame;
      Result := true;
    end
    else
    if PlayersBothPoints > gmEndGame then
    begin
      if MsgBox(gmCongratLossText) then
      begin
        StopGame;
        StartGame;
      end
      else
        StopGame;
      Result := true;
    end;
  end;

end;

procedure TMain.StartGame;
var
  Xn, Yn: Integer;
  I, J: Integer;
begin
  if GameExit then Exit;

  GameStarted := true;
  CardsDrag := false;
  N3.Enabled := false;
  N5.Enabled := false;

  Xn := gmMatrixCardsX;
  Yn := gmMatrixCardsY;

  for J := 0 to gmMaxCardsY - 1 do
  begin
    for I := 0 to gmMaxCardsX - 1 do
    begin
      MoveCards[I, J].Number := GetNumberCard;
      MoveCards[I, J].Theme := GetColourCard(MoveCards[I, J].Number - 1);
      MoveCards[I, J].Show;
      MoveCards[I, J].Move(Xn, Yn, gmMoveStartGameCardXY);
      Xn := Xn + gmCardsWidth + gmDistanceCardsX;
      if GameExit then Exit;
    end;
    Xn := gmMatrixCardsX;
    Yn := Yn + gmCardsHeight + gmDistanceCardsY;
    if GameExit then Exit;
  end;

  CardsDrag := true;
  N3.Enabled := true;
  N5.Enabled := true;

  PlayersBothPointsText := gmPlayersBothPointsText + ' ' + InttoStr(PlayersBothPoints);

  if Configuration.ReadBool(gmIniMainInfo, gmIniBeginFirstUser, false) then
  begin
    CourseText := gmCourseUserText;
    Invalidate;
  end
  else
  begin
    CourseText := gmCourseComputerText;
    Invalidate;
    Computer;
  end;
  
end;

procedure TMain.StopGame;
var
  I, J: Integer;
  Pos: TPoint;
begin
  if GameExit then Exit;

  GameStarted := false;

  N3.Enabled := false;
  N5.Enabled := false;
  CardsDrag := false;

  PlayersBothPointsText := '';
  CourseText := '';
  Invalidate;

  PlayersBothPoints := 0;

  Pos := Point(PackCards[gmMaxPackCards - 1].Left,
   PackCards[gmMaxPackCards - 1].Top);

  for J := 0 to gmMaxCardsY - 1 do
  begin
    for I := 0 to gmMaxCardsX - 1 do
    begin
      if MoveCards[I, J].Visible then
      begin
        MoveCards[I, J].BringToFront;
        MoveCards[I, J].Move(Pos.X, Pos.Y, gmMoveStopGameCardXY);
        MoveCards[I, J].Hide;
      end
      else
      begin
        MoveCards[I, J].Left := Pos.X;
        MoveCards[I, J].Top := Pos.Y;
      end;
      if GameExit then Exit;
    end;
    if GameExit then Exit;
  end;

  for I := TargetUserList.Count - 1 downto 0 do
  begin
    TargetUserList.Items[I].BringToFront;
    TargetUserList.Items[I].Move(Pos.X, Pos.Y, gmMoveStopGameCardXY);
    TargetUserList.Items[I].Hide;
    if GameExit then Exit;
  end;

  TargetUserList.Clear;


  for I := TargetComputerList.Count - 1 downto 0 do
  begin
    TargetComputerList.Items[I].BringToFront;
    TargetComputerList.Items[I].Move(Pos.X, Pos.Y, gmMoveStopGameCardXY);
    TargetComputerList.Items[I].Hide;
    if GameExit then Exit;
  end;

  TargetComputerList.Clear;

  N3.Enabled := true;
  N5.Enabled := true;
  CardsDrag := true;

end;

function TMain.MsgBox(Text: string): Boolean;
begin
  Result := Application.MessageBox(PChar(Text), PChar(Caption),
   MB_OKCANCEL or MB_ICONASTERISK) = 1;
end;

procedure TMain.N3Click(Sender: TObject);
begin
  if Not GameStarted then
    StartGame
  else
  begin
    StopGame;
    StartGame;
  end;
end;

function TMain.GetNumberCard: Integer;
begin
  Result := Random(6) + 1;
end;

function TMain.GetColourCard(N: Integer): TBitmap;
begin
  case Configuration.ReadInteger(gmIniMainInfo, gmIniColourCards, 0) of
    0: Result := ResourceManager.GameCards[N].gcChervi;
    1: Result := ResourceManager.GameCards[N].gcPiki;
    2: Result := ResourceManager.GameCards[N].gcTrefi;
    3: Result := ResourceManager.GameCards[N].gcBubni;
  else
    case Random(4) of
      0: Result := ResourceManager.GameCards[N].gcChervi;
      1: Result := ResourceManager.GameCards[N].gcPiki;
      2: Result := ResourceManager.GameCards[N].gcTrefi;
      3: Result := ResourceManager.GameCards[N].gcBubni;
    end;
  end;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GameExit := true;
end;

procedure TMain.Computer;
var
  I: Integer;
  Dest: TMoveCard;
  mxPos: TPoint;
  Pos: TPoint;
begin
  CardsDrag := false;
  N3.Enabled := false;
  for I := 0 to gmComputerSleep - 1 do
    Application.ProcessMessages;
  Dest := GetComputerCard;
  mxPos := Point(Dest.Left, Dest.Top);
  Pos := GetComputerCardXY;
  Dest.BringToFront;
  Dest.Move(Pos.X, Pos.Y, gmMoveComputerCardXY);
  CardsComputerDragDrop(Dest, mxPos);
  CardsDrag := true;
  N3.Enabled := true;
end;

{ TTargetList }

function TTargetList.Add: TTargetCard;
begin
  Result := TTargetCard.Create(Main);
  inherited Add(Pointer(Result));
end;

procedure TTargetList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited;
end;

function TTargetList.GetItems(I: Integer): TTargetCard;
begin
  Result := TTargetCard(inherited Items[I]);
end;

function TMain.GetTargetUserPoint(X, Y: Integer): Boolean;
var
  Xn, Yn, Xw, Yh: Integer;
  I: Integer;
begin
  Result := false;

  Xn := TargetUser.Left;
  Yn := TargetUser.Top;
  Xw := Xn + TargetUser.Width;
  Yh := Yn + TargetUser.Height;

  if (X >= Xn) and (Y >= Yn) and (X <= Xw) and (Y <= Yh) then
    Result := true;

  if Result then Exit;

  for I := 0 to TargetUserList.Count - 1 do
  begin
    Xn := TargetUserList.Items[I].Left;
    Yn := TargetUserList.Items[I].Top;
    Xw := Xn + TargetUserList.Items[I].Width;
    Yh := Yn + TargetUserList.Items[I].Height;
    if (X >= Xn) and (Y >= Yn) and (X <= Xw) and (Y <= Yh) then
    begin
      Result := true;
      Break;
    end;
  end;
  
end;

function TMain.GetUserCardXY: TPoint;
begin
  Result.Y := TargetUser.Top + 5;
  if TargetUserList.Count = 0 then
    Result.X := TargetUser.Left + 5
  else
    Result.X := TargetUserList.Items[TargetUserList.Count - 1].Left + 15;
end;

procedure TMain.NextCard(Dest: TMoveCard; mxPos: TPoint);
begin
  if Configuration.ReadBool(gmIniMainInfo, gmIniNextCard, true) then
  begin
    CardsDrag := false;
    N3.Enabled := false;
    Dest.Left := PackCards[gmMaxPackCards - 1].Left;
    Dest.Top := PackCards[gmMaxPackCards - 1].Top;
    Dest.Number := GetNumberCard;
    Dest.Theme := GetColourCard(Dest.Number - 1);
    Dest.Show;
    Dest.Move(mxPos.X, mxPos.Y, gmMoveStartGameCardXY);
    CardsDrag := true;
    N3.Enabled := true;
  end;
end;

procedure TMain.CardsComputerDragDrop(Dest: TMoveCard; mxPos: TPoint);
begin
  Dest.Hide;
  with TargetComputerList.Add do
  begin
    Left := Dest.Left;
    Top := Dest.Top;
    Theme := Dest.Theme;
    Number := Dest.Number;
    Parent := Self;
  end;
  PlayersBothPoints := PlayersBothPoints + Dest.Number;
  PlayersBothPointsText := gmPlayersBothPointsText + ' ' + InttoStr(PlayersBothPoints);
  Invalidate;
  if EndGame(true) then Exit;
  NextCard(Dest, mxPos);
  CourseText := gmCourseUserText;
  Invalidate;
end;

function TMain.GetComputerCardXY: TPoint;
begin
  Result.Y := TargetComputer.Top + 5;
  if TargetComputerList.Count = 0 then
    Result.X := TargetComputer.Left + 5
  else
    Result.X := TargetComputerList.Items[TargetComputerList.Count - 1].Left + 15;
end;

function TMain.GetComputerCard: TMoveCard;
var
  Number: Integer;
begin
  Result := nil;
  
  case PlayersBothPoints of
    30: Result := GetCardNumber(6);
    31: Result := GetCardNumber(5);
    32: Result := GetCardNumber(4);
    33: Result := GetCardNumber(3);
    34: Result := GetCardNumber(2);
    35: Result := GetCardNumber(1);
    37: Result := GetCardNumber(6);
    38: Result := GetCardNumber(5);
    39: Result := GetCardNumber(4);
    40: Result := GetCardNumber(3);
    41: Result := GetCardNumber(2);
    42: Result := GetCardNumber(1);
    44: Result := GetCardNumber(6);
    45: Result := GetCardNumber(5);
    46: Result := GetCardNumber(4);
    47: Result := GetCardNumber(3);
    48: Result := GetCardNumber(2);
    49: Result := GetCardNumber(1);
  end;

  if Result <> nil then Exit;

  repeat
    Result := MoveCards[Random(gmMaxCardsX), Random(gmMaxCardsY)];
  until Result.Visible <> false;  

end;

procedure TMain.Exception(Sender: TObject; E: Exception);
begin
  Application.MessageBox(PChar(E.Message), PChar(Caption), MB_OK or MB_ICONERROR);
  Application.Terminate;
end;

procedure TMain.N7Click(Sender: TObject);
begin
  Close;
end;

procedure TMain.N9Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'Help.chm', nil, PChar(ExtractFileDir(Application.ExeName)), SW_SHOW);
end;

function TMain.GetCardNumber(N: Integer): TMoveCard;
var
  I, J: Integer;
begin
  Result := nil;
  for I := 0 to gmMaxCardsX - 1 do
  begin
    for J := 0 to gmMaxCardsY - 1 do
    begin
      if (MoveCards[I, J].Number = N) and MoveCards[I, J].Visible then
      begin
        Result := MoveCards[I, J];
        Break;
      end;
    end;
  end;
end;

initialization
  Configuration := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\Configuration.ini');
  gmMoveCardsSleep := Configuration.ReadInteger(gmIniMainInfo, gmIniMoveCardsSleep, 250000);
  gmMoveCardXY := Configuration.ReadInteger(gmIniMainInfo, gmIniMoveCardXY, 23);
  gmMoveStartGameCardXY := Configuration.ReadInteger(gmIniMainInfo, gmIniMoveStartGameCardXY, 50);
  gmMoveStopGameCardXY := Configuration.ReadInteger(gmIniMainInfo, gmIniMoveStopGameCardXY, 110);
  gmMovePackCardXY := Configuration.ReadInteger(gmIniMainInfo, gmIniMovePackCardXY, 50);
  gmMoveComputerCardXY := Configuration.ReadInteger(gmIniMainInfo, gmIniMoveComputerCardXY, 30);
  gmComputerSleep := Configuration.ReadInteger(gmIniMainInfo, gmIniComputerSleep, 80000000);

  ResourceManager := TResourceManager.Create;

finalization
  ResourceManager.Free;
  Configuration.Free;

end.
