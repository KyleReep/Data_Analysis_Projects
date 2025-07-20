Attribute VB_Name = "Module1"
Sub SaveFilteredAttachments()
    Dim olNS As Outlook.NameSpace
    Dim selectedFolder As Outlook.MAPIFolder
    Dim chosenCategory As String
    Dim extFilter As String
    Dim fileTypes() As String
    Dim savePath As String
    Dim mail As Object
    Dim att As Attachment
    Dim i As Long
    Dim dlgFolder As Object
    Dim catForm As frmCategoryPicker
    Dim dateInput As String
    Dim startDate As Date
    Dim isValidDate As Boolean
    Dim matchedItems As Long

    Set olNS = Application.GetNamespace("MAPI")

    ' === 1. Select Mail Folder ===
    Set selectedFolder = olNS.PickFolder
    If selectedFolder Is Nothing Then
        MsgBox "No folder selected. Exiting.", vbExclamation
        Exit Sub
    End If

    ' === 2. Show Category Picker Form ===
    Set catForm = New frmCategoryPicker
    catForm.Show

    If catForm.Category = "" Then
        MsgBox "No category selected. Exiting.", vbExclamation
        Exit Sub
    End If
    chosenCategory = catForm.Category

    ' === 3. Ask for File Extensions ===
    extFilter = InputBox("Enter file extensions to save (comma-separated, e.g. pdf,docx):", "File Extensions")
    If Trim(extFilter) = "" Then
        MsgBox "No extensions provided. Exiting.", vbExclamation
        Exit Sub
    End If
    fileTypes = Split(LCase(extFilter), ",")

    ' === 4. Ask for Start Date ===
    Do
        dateInput = InputBox("Enter the start date (YYYY-MM-DD):", "Export Emails From This Date")
        If IsDate(dateInput) Then
            startDate = CDate(dateInput)
            isValidDate = True
        ElseIf dateInput = "" Then
            MsgBox "No date entered. Exiting.", vbExclamation
            Exit Sub
        Else
            MsgBox "Invalid date format. Please enter in YYYY-MM-DD format.", vbExclamation
        End If
    Loop Until isValidDate

    ' === 5. Ask Where to Save Files ===
    Set dlgFolder = Application.FileDialog(4) 'msoFileDialogFolderPicker
    With dlgFolder
        .Title = "Select folder to save attachments to"
        .AllowMultiSelect = False
        If .Show <> -1 Then
            MsgBox "No folder selected. Exiting.", vbExclamation
            Exit Sub
        End If
        savePath = .SelectedItems(1)
    End With
    If Right(savePath, 1) <> "\" Then savePath = savePath & "\"

    ' === 6. Loop through emails and save attachments ===
    matchedItems = 0
    For Each mail In selectedFolder.Items
        If TypeOf mail Is Outlook.MailItem Then
            If mail.ReceivedTime >= startDate Then
                If InStr(1, mail.Categories, chosenCategory, vbTextCompare) > 0 Then
                    For i = mail.Attachments.Count To 1 Step -1
                        Set att = mail.Attachments(i)
                        Dim ext As String
                        ext = LCase(Mid(att.FileName, InStrRev(att.FileName, ".") + 1))
                        If IsInArray(ext, fileTypes) Then
                            Dim fullPath As String
                            fullPath = savePath & att.FileName
                            fullPath = GetUniqueFilename(fullPath)
                            att.SaveAsFile fullPath
                            matchedItems = matchedItems + 1
                        End If
                    Next i
                End If
            End If
        End If
    Next mail

    MsgBox "Done. Saved " & matchedItems & " attachments from emails matching category '" & chosenCategory & "' and date " & Format(startDate, "yyyy-mm-dd") & ".", vbInformation
End Sub

' === Helper: Check if a value is in an array ===
Function IsInArray(val As String, arr As Variant) As Boolean
    Dim x As Variant
    For Each x In arr
        If Trim(x) = val Then
            IsInArray = True
            Exit Function
        End If
    Next
    IsInArray = False
End Function

' === Helper: Avoid overwriting files ===
Function GetUniqueFilename(filePath As String) As String
    Dim fso As Object
    Dim baseName As String
    Dim ext As String
    Dim counter As Long
    Dim newPath As String

    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(filePath) Then
        GetUniqueFilename = filePath
        Exit Function
    End If

    baseName = Left(filePath, InStrRev(filePath, ".") - 1)
    ext = Mid(filePath, InStrRev(filePath, "."))

    Do
        counter = counter + 1
        newPath = baseName & "_" & counter & ext
    Loop While fso.FileExists(newPath)

    GetUniqueFilename = newPath
End Function

