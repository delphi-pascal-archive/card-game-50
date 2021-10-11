unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls;

type
  TListBox = class(StdCtrls.TListBox)
  private
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
  end;

  TOption = class(TForm)
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    GroupBox4: TGroupBox;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Option: TOption;

implementation

uses Unit1;

{$R *.dfm}

procedure TOption.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to gmMaxShirts - 1 do
    ListBox1.Items.Add('');
  ListBox1.ItemIndex := Configuration.ReadInteger(gmIniMainInfo, gmIniShirtIndex, 0);
  CheckBox1.Checked := Configuration.ReadBool(gmIniMainInfo, gmIniBeginFirstUser, false);
  CheckBox2.Checked := Configuration.ReadBool(gmIniMainInfo, gmIniNextCard, true);
  ComboBox1.ItemIndex := Configuration.ReadInteger(gmIniMainInfo, gmIniColourCards, 0);
end;

procedure TOption.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  if odSelected in State then
    ListBox1.Canvas.RoundRect(Rect.Left, Rect.Top, Rect.Left + gmCardsWidth + 4, gmCardsHeight + 4, 2, 2)
  else
    ListBox1.Canvas.FillRect(Classes.Rect(Rect.Left, Rect.Top,
    Rect.Left + gmCardsWidth + 4, gmCardsHeight + 4));
  ListBox1.Canvas.Draw(Rect.Left + 2, Rect.Top + 2, ResourceManager.GameShirts[Index]);
end;

{ TListBox }

procedure TListBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
    State := TOwnerDrawState(LongRec(itemState).Lo);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clHighlightText
    end;
    if Integer(itemID) >= 0 then
      DrawItem(itemID, rcItem, State) else
      Canvas.FillRect(rcItem);
    Canvas.Handle := 0;
  end;
end;

procedure TOption.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TOption.Button1Click(Sender: TObject);
var
  I, J: Integer;
begin
  Configuration.WriteInteger(gmIniMainInfo, gmIniShirtIndex, ListBox1.ItemIndex);
  for I := 0 to gmMaxPackCards - 1 do
    Main.PackCards[I].Theme := ResourceManager.GameShirts[ListBox1.ItemIndex];
  Main.Invalidate;
  Configuration.WriteBool(gmIniMainInfo, gmIniBeginFirstUser, CheckBox1.Checked);
  Configuration.WriteBool(gmIniMainInfo, gmIniNextCard, CheckBox2.Checked);
  Configuration.WriteInteger(gmIniMainInfo, gmIniColourCards, ComboBox1.ItemIndex);
  if Main.GameStarted then
  begin
    for J := 0 to gmMaxCardsY - 1 do
      for I := 0 to gmMaxCardsX - 1 do
        Main.MoveCards[I, J].Theme := Main.GetColourCard(Main.MoveCards[I, J].Number - 1);
        
    for I := 0 to Main.TargetUserList.Count - 1 do
      Main.TargetUserList.Items[I].Theme := Main.GetColourCard(Main.TargetUserList.Items[I].Number - 1);
    for I := 0 to Main.TargetComputerList.Count - 1 do
      Main.TargetComputerList.Items[I].Theme := Main.GetColourCard(Main.TargetComputerList.Items[I].Number - 1);
  end;
  Close;
end;

end.
