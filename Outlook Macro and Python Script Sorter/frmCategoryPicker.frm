VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmCategoryPicker 
   Caption         =   "Please Select Export Category"
   ClientHeight    =   2016
   ClientLeft      =   108
   ClientTop       =   456
   ClientWidth     =   4620
   OleObjectBlob   =   "frmCategoryPicker.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmCategoryPicker"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' === frmCategoryPicker UserForm code ===
Private selectedCategory As String

' Public property to get the selected category after form closes
Public Property Get Category() As String
    Category = selectedCategory
End Property

' Public property to receive the Outlook folder from the main macro
Private pSelectedFolder As Outlook.MAPIFolder

Public Property Get selectedFolder() As Outlook.MAPIFolder
    Set selectedFolder = pSelectedFolder
End Property

Public Property Set selectedFolder(value As Outlook.MAPIFolder)
    Set pSelectedFolder = value
End Property


Private Sub UserForm_Initialize()
    Dim mail As Object
    Dim cats() As String
    Dim c As Variant
    Dim catDict As Object
    
    Set catDict = CreateObject("Scripting.Dictionary")
    
    ' Make sure the folder was set by the main macro
    If selectedFolder Is Nothing Then
        MsgBox "No folder provided to form. Closing.", vbExclamation
        Unload Me
        Exit Sub
    End If
    
    ' Loop through each mail in the folder, collect unique categories
    For Each mail In selectedFolder.Items
        If TypeOf mail Is Outlook.MailItem Then
            If mail.Categories <> "" Then
                cats = Split(mail.Categories, ",")
                For Each c In cats
                    c = Trim(c)
                    If Not catDict.Exists(c) Then
                        catDict.Add c, True
                        cmbCategory.AddItem c
                    End If
                Next c
            End If
        End If
    Next mail
    
    ' If no categories found, warn and close the form
    If cmbCategory.ListCount = 0 Then
        MsgBox "No categories found in the selected folder's emails.", vbInformation
        Unload Me
    End If
End Sub

Private Sub btnOK_Click()
    If cmbCategory.ListIndex <> -1 Then
        selectedCategory = cmbCategory.value
        Me.Hide
    Else
        MsgBox "Please select a category.", vbExclamation
    End If
End Sub

