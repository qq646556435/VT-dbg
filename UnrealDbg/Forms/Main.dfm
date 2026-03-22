object AppWnd: TConfigWnd
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'System Monitor'
  ClientHeight = 510
  ClientWidth = 882
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object memoLog1: TRichEdit
    Left = 8
    Top = 282
    Width = 866
    Height = 220
    BorderWidth = 2
    Color = clBlack
    Font.Charset = GB2312_CHARSET
    Font.Color = clLime
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    Lines.Strings = (
      'memoLog1')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object grpBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 401
    Height = 121
    Caption = 'System profile'
    TabOrder = 1
    object lblSysName: TLabel
      Left = 16
      Top = 24
      Width = 51
      Height = 15
      Caption = 'OS name:'
    end
    object lblSysVer: TLabel
      Left = 16
      Top = 56
      Width = 51
      Height = 15
      Caption = 'OS version:'
    end
    object lblCpu: TLabel
      Left = 17
      Top = 88
      Width = 50
      Height = 15
      Caption = 'Processor:'
    end
  end
  object grpBox2: TGroupBox
    Left = 8
    Top = 135
    Width = 401
    Height = 137
    Caption = 'Controls'
    TabOrder = 2
    object chkFlag1: TCheckBox
      Left = 17
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Feature A'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 0
    end
    object chkFlag2: TCheckBox
      Left = 17
      Top = 70
      Width = 97
      Height = 17
      Caption = 'Feature B'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 1
    end
    object chkFlag3: TCheckBox
      Left = 17
      Top = 47
      Width = 97
      Height = 17
      Caption = 'Feature C'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 2
    end
    object chkFlag4: TCheckBox
      Left = 17
      Top = 93
      Width = 97
      Height = 17
      Caption = 'Feature D'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 3
    end
    object chkFlag5: TCheckBox
      Left = 17
      Top = 116
      Width = 97
      Height = 17
      Caption = 'Feature E'
      Enabled = False
      TabOrder = 4
    end
    object chkFlag6: TCheckBox
      Left = 158
      Top = 24
      Width = 115
      Height = 17
      Caption = 'Feature F'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 5
    end
    object btnAction1: TButton
      Left = 155
      Top = 61
      Width = 166
      Height = 63
      Caption = 'Start service'
      TabOrder = 6
      OnClick = btnAction1Click
    end
  end
  object pageMain1: TPageControl
    Left = 432
    Top = 8
    Width = 442
    Height = 268
    ActivePage = tabSheet1
    TabOrder = 3
    object tabSheet1: TTabSheet
      Caption = 'Items'
      object listItems1: TListView
        Left = 3
        Top = 3
        Width = 428
        Height = 232
        Columns = <
          item
            Caption = '#'
          end
          item
            Caption = 'Name'
            Width = 200
          end
          item
            Caption = 'Path'
            Width = 500
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnMouseDown = listItems1MouseDown
      end
    end
    object tabSheet2: TTabSheet
      Caption = 'Advanced'
      ImageIndex = 1
      DesignSize = (
        434
        238)
      object pageSub1: TPageControl
        Left = 3
        Top = 3
        Width = 428
        Height = 232
        ActivePage = tabSheet3
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        object tabSheet3: TTabSheet
          Caption = 'Module A'
          object imgPick1: TImage
            Left = 369
            Top = 167
            Width = 32
            Height = 32
            AutoSize = True
            Picture.Data = {
              055449636F6E0000010001002020100000000000E80200001600000028000000
              2000000040000000010004000000000080020000000000000000000000000000
              0000000000000000000080000080000000808000800000008000800080800000
              80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
              FFFFFF0000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFF
              FFFFFFF000FFFFFFFFFFFF00000FFFFFFFFFFFF000FFFFFFFFFF00FF0FF00FFF
              FFFFFFF000FFFFFFFFF0FF00000FF0FFFFFFFFF000FFFFFFFF0FFFFF0FFFFF0F
              FFFFFFF000FFFFFFF0FFFF00000FFFF0FFFFFFF000FFFFFFF0FFFFFF0FFFFFF0
              FFFFFFF000FFFFFF0F0F0FF000FF0F0F0FFFFFF000FFFFFF0F0F0F0FFF0F0F0F
              0FFFFFF000FFFFFF0000000F0F0000000FFFFFF000FFFFFF0F0F0F0FFF0F0F0F
              0FFFFFF000FFFFFF0F0F0FF000FF0F0F0FFFFFF000FFFFFFF0FFFFFF0FFFFFF0
              FFFFFFF000FFFFFFF0FFFF00000FFFF0FFFFFFF000FFFFFFFF0FFFFF0FFFFF0F
              FFFFFFF000FFFFFFFFF0FF00000FF0FFFFFFFFF000FFFFFFFFFF00FF0FF00FFF
              FFFFFFF000FFFFFFFFFFFF00000FFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFF
              FFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFF
              FFFFFFF000000000000000000000000000000000008880CCCCCCCCCCCCCCCCCC
              CCC08880008080CCCCCCCCCCCCCCCCCCCCC08080008880CCCCCCCCCCCCCCCCCC
              CCC0888000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000FFFFFFFF800000008000000080000000800000008000000080000000
              8000000080000000800000008000000080000000800000008000000080000000
              8000000080000000800000008000000080000000800000008000000080000000
              800000008000000080000000800000008000000080000000FFFFFFFFFFFFFFFF
              FFFFFFFF}
            OnMouseDown = imgPick1MouseDown
            OnMouseMove = imgPick1MouseMove
            OnMouseUp = imgPick1MouseUp
          end
          object lblDrag: TLabel
            Left = 260
            Top = 178
            Width = 99
            Height = 15
            Caption = 'Drag to select target window'
          end
          object lblNote: TLabel
            Left = 17
            Top = 135
            Width = 237
            Height = 45
            Caption = 
              'Note: advanced options may require application restart after up' +
              'dates.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clRed
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object chkOpt7: TCheckBox
            Left = 16
            Top = 3
            Width = 137
            Height = 17
            Caption = 'Enable module hooks'
            TabOrder = 0
            OnClick = chkOpt7Click
          end
          object grpBox3: TGroupBox
            Left = 19
            Top = 33
            Width = 174
            Height = 96
            Caption = 'Sub-options'
            TabOrder = 1
            object chkOpt8: TCheckBox
              Left = 16
              Top = 32
              Width = 169
              Height = 17
              Caption = 'Timer consistency check'
              TabOrder = 0
              OnClick = chkOpt8Click
            end
            object chkOpt9: TCheckBox
              Left = 16
              Top = 56
              Width = 137
              Height = 17
              Caption = 'Suspend worker threads'
              Enabled = False
              TabOrder = 1
              OnClick = chkOpt9Click
            end
          end
        end
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 796
    Top = 82
  end
  object popMenu1: TPopupMenu
    Left = 684
    Top = 90
    object mnuCmd1: TMenuItem
      Caption = 'Run'
      OnClick = mnuCmd1Click
    end
    object mnuCmd2: TMenuItem
      Caption = 'Add'
      OnClick = mnuCmd2Click
    end
    object mnuCmd3: TMenuItem
      Caption = 'Remove'
      OnClick = mnuCmd3Click
    end
  end
end
