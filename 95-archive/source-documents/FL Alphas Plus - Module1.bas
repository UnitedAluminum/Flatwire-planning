Attribute VB_Name = "Module1"
Option Explicit

'====================================================
' GLOBAL STORAGE
'====================================================
Public Segments() As SegmentType
Public SegmentCount As Long

Public Type SegmentType
Rod As String
Alpha As String
Weight As Double
SpoolID As Long
End Type

'====================================================
' MAIN PROCESS
'====================================================
Sub RunProduction()

Call GenerateFL1_Optimized
Call GenerateFL2_Optimized
Call UpdateDashboard

MsgBox "Production Complete"

End Sub

'====================================================
' FL1 OPTIMIZED
'
' PURPOSE:
' 1. Build production spools
' 2. Ensure FL2 can ALWAYS create valid stops
' 3. Minimize overproduction
'====================================================
Sub GenerateFL1_Optimized()

Dim wsIn As Worksheet
Dim wsOut As Worksheet

Set wsIn = Sheets("INPUT")
Set wsOut = Sheets("FL1")

wsOut.Cells.Clear

wsOut.Range("A1:D1").Value = Array( _
    "Spool #", _
    "Spool Weight", _
    "Rod Consumption", _
    "Spool Alpha")

'================================================
' INPUTS
'================================================

Dim startRod As String
Dim rodWeight As Double
Dim orderWeight As Double
Dim targetSpoolWeight As Double

Dim stopMin As Double
Dim stopMax As Double

startRod = wsIn.Range("C2").Value
rodWeight = wsIn.Range("C3").Value
orderWeight = wsIn.Range("C4").Value
targetSpoolWeight = wsIn.Range("C5").Value

stopMin = wsIn.Range("C6").Value
stopMax = wsIn.Range("C7").Value

'================================================
' INITIALIZATION
'================================================

Dim currentRod As String
Dim rodsRemaining As Double
Dim alphaIndex As Long

currentRod = startRod
rodsRemaining = rodWeight
alphaIndex = 1

Dim spoolWeights() As Double
Dim spoolCount As Long

spoolCount = 0

'================================================
' BUILD OPTIMIZED SPOOL LIST
'================================================

Dim remainingOrder As Double
remainingOrder = orderWeight

Do While remainingOrder > 0

    Dim proposedSpool As Double

    If remainingOrder >= targetSpoolWeight Then
        proposedSpool = targetSpoolWeight
    Else
        proposedSpool = remainingOrder
    End If

    '============================================
    ' VALIDATE FINAL STOP POSSIBILITY
    '============================================

    Dim remainder As Double

    remainder = proposedSpool Mod stopMax

    If remainder > 0 Then

        If remainder < stopMin Then

            proposedSpool = proposedSpool + (stopMin - remainder)

        End If

    End If

    ' Prevent spool exceeding total remaining order too aggressively
    If proposedSpool > remainingOrder + stopMax Then
        proposedSpool = remainingOrder + stopMin
    End If

    spoolCount = spoolCount + 1

    ReDim Preserve spoolWeights(1 To spoolCount)

    spoolWeights(spoolCount) = proposedSpool

    remainingOrder = remainingOrder - targetSpoolWeight

Loop

'================================================
' BUILD PHYSICAL SEGMENTS
'================================================

Erase Segments
SegmentCount = 0

Dim rowNum As Long
rowNum = 2

Dim spoolNum As Long

For spoolNum = 1 To spoolCount

    Dim spoolRemaining As Double
    spoolRemaining = spoolWeights(spoolNum)

    Dim spoolAlpha As String
    Dim consumption As String

    spoolAlpha = ""
    consumption = ""

    Do While spoolRemaining > 0

        If rodsRemaining <= 0 Then

            currentRod = IncrementRod(currentRod)

            rodsRemaining = rodWeight

            alphaIndex = 1

        End If

        Dim used As Double

        If rodsRemaining >= spoolRemaining Then
            used = spoolRemaining
        Else
            used = rodsRemaining
        End If

        Dim alphaCode As String

        alphaCode = currentRod & AlphaLetter(alphaIndex)

        If spoolAlpha <> "" Then
            spoolAlpha = spoolAlpha & " - "
            consumption = consumption & " / "
        End If

        spoolAlpha = spoolAlpha & alphaCode

        consumption = consumption & _
                      currentRod & _
                      " (" & used & " lbs)"

        SegmentCount = SegmentCount + 1

        ReDim Preserve Segments(1 To SegmentCount)

        Segments(SegmentCount).Rod = currentRod
        Segments(SegmentCount).Alpha = alphaCode
        Segments(SegmentCount).Weight = used
        Segments(SegmentCount).SpoolID = spoolNum

        rodsRemaining = rodsRemaining - used

        spoolRemaining = spoolRemaining - used

        alphaIndex = alphaIndex + 1

    Loop

    wsOut.Cells(rowNum, 1).Value = spoolNum
    wsOut.Cells(rowNum, 2).Value = spoolWeights(spoolNum)
    wsOut.Cells(rowNum, 3).Value = consumption
    wsOut.Cells(rowNum, 4).Value = spoolAlpha

    rowNum = rowNum + 1

Next spoolNum

MsgBox "FL1 Optimized Complete"

End Sub

'====================================================
' FL2 OPTIMIZED
'
' RULE:
' A STOP MAY USE MULTIPLE ALPHAS
' BUT ONLY FROM THE SAME SPOOL
'====================================================
Sub GenerateFL2_Optimized()

    Dim wsIn As Worksheet
    Dim wsOut As Worksheet

    Set wsIn = Sheets("INPUT")
    Set wsOut = Sheets("FL2")

    wsOut.Cells.Clear

    wsOut.Range("A1:D1").Value = Array( _
        "Stop #", _
        "Stop Weight", _
        "Source Alpha", _
        "Stop Alpha")

    If SegmentCount = 0 Then
        MsgBox "Run FL1 First"
        Exit Sub
    End If

    Dim stopMin As Double
    Dim stopMax As Double

    stopMin = wsIn.Range("C6").Value
    stopMax = wsIn.Range("C7").Value

    Dim stopNum As Long
    Dim rowNum As Long

    stopNum = 1
    rowNum = 2

    Dim segIndex As Long
    segIndex = 1

    Do While segIndex <= SegmentCount

        Dim currentSpool As Long
        currentSpool = Segments(segIndex).SpoolID

        '=========================================
        ' CALCULATE TOTAL WEIGHT FOR THIS SPOOL
        '=========================================

        Dim spoolTotal As Double
        spoolTotal = 0

        Dim tempIndex As Long
        tempIndex = segIndex

        Do While tempIndex <= SegmentCount

            If Segments(tempIndex).SpoolID <> currentSpool Then
                Exit Do
            End If

            spoolTotal = spoolTotal + Segments(tempIndex).Weight

            tempIndex = tempIndex + 1

        Loop

        '=========================================
        ' PROCESS THIS SPOOL INTO STOPS
        '=========================================

        Dim spoolRemaining As Double
        spoolRemaining = spoolTotal

        Dim workingIndex As Long
        workingIndex = segIndex

        Dim segRemaining As Double
        segRemaining = Segments(workingIndex).Weight

        Dim stopAlphaCounter As Long
        stopAlphaCounter = 1

        Do While spoolRemaining > 0

            Dim thisStop As Double

            If spoolRemaining >= stopMax Then
                thisStop = stopMax
            Else
                thisStop = spoolRemaining
            End If

            '-------------------------------------
            ' PREVENT INVALID FINAL REMAINDER
            '-------------------------------------

            Dim remainder As Double
            remainder = spoolRemaining - thisStop

            If remainder > 0 Then

                If remainder < stopMin Then
                    thisStop = spoolRemaining
                End If

            End If

            '-------------------------------------
            ' BUILD STOP FROM MULTIPLE ALPHAS
            '-------------------------------------

            Dim stopFill As Double
            stopFill = 0

            Dim sourceText As String
            sourceText = ""

            Dim stopAlphaText As String
            stopAlphaText = ""
            
            Dim alphaParts() As String
            Dim alphaPartCount As Long

            alphaPartCount = 0

            Do While stopFill < thisStop

                Dim needed As Double
                needed = thisStop - stopFill

                Dim used As Double

                If segRemaining >= needed Then
                    used = needed
                Else
                    used = segRemaining
                End If

                If sourceText <> "" Then
                    sourceText = sourceText & " / "
                End If
                
                sourceText = sourceText & _
                    Segments(workingIndex).Alpha & _
                    " (" & used & " lbs)"
                
                alphaPartCount = alphaPartCount + 1
                
                ReDim Preserve alphaParts(1 To alphaPartCount)
                
                alphaParts(alphaPartCount) = _
                    Segments(workingIndex).Alpha & _
                    AlphaLetter(stopAlphaCounter)

                stopFill = stopFill + used

                segRemaining = segRemaining - used

                If segRemaining <= 0 Then

                    workingIndex = workingIndex + 1

                    If workingIndex <= SegmentCount Then

                        If Segments(workingIndex).SpoolID = currentSpool Then
                            segRemaining = Segments(workingIndex).Weight
                        End If

                    End If

                End If

            Loop
            
            Dim revIndex As Long

            For revIndex = alphaPartCount To 1 Step -1

                If stopAlphaText <> "" Then
                    stopAlphaText = stopAlphaText & " - "
                End If
        
                stopAlphaText = stopAlphaText & alphaParts(revIndex)
        
            Next revIndex

            '-------------------------------------
            ' OUTPUT STOP
            '-------------------------------------

            wsOut.Cells(rowNum, 1).Value = stopNum
            wsOut.Cells(rowNum, 2).Value = thisStop
            wsOut.Cells(rowNum, 3).Value = sourceText
            wsOut.Cells(rowNum, 4).Value = stopAlphaText

            spoolRemaining = spoolRemaining - thisStop

            stopNum = stopNum + 1
            rowNum = rowNum + 1
            stopAlphaCounter = stopAlphaCounter + 1

        Loop

        segIndex = tempIndex

    Loop

    MsgBox "FL2 Optimized Complete"

End Sub

'====================================================
' DASHBOARD
'====================================================
Sub UpdateDashboard()

Dim wsIn As Worksheet
Dim wsFL1 As Worksheet
Dim wsFL2 As Worksheet

Set wsIn = Sheets("INPUT")
Set wsFL1 = Sheets("FL1")
Set wsFL2 = Sheets("FL2")

Dim lastRow1 As Long
Dim lastRow2 As Long

lastRow1 = wsFL1.Cells(wsFL1.Rows.Count, 1).End(xlUp).Row
lastRow2 = wsFL2.Cells(wsFL2.Rows.Count, 1).End(xlUp).Row

Dim totalSpools As Long
Dim totalStops As Long

totalSpools = WorksheetFunction.Max(lastRow1 - 1, 0)
totalStops = WorksheetFunction.Max(lastRow2 - 1, 0)

Dim totalOutput As Double
totalOutput = 0

Dim i As Long

For i = 2 To lastRow1

    totalOutput = totalOutput + wsFL1.Cells(i, 2).Value

Next i

Dim rodWeight As Double
rodWeight = wsIn.Range("C3").Value

Dim rodsUsed As Long
rodsUsed = 0

If rodWeight > 0 Then

    rodsUsed = WorksheetFunction.RoundUp( _
        totalOutput / rodWeight, 0)

End If

Dim efficiency As Double

If rodsUsed * rodWeight > 0 Then

    efficiency = totalOutput / (rodsUsed * rodWeight)

Else

    efficiency = 0

End If

wsIn.Range("H2").Value = rodsUsed
wsIn.Range("H3").Value = totalSpools
wsIn.Range("H4").Value = totalStops
wsIn.Range("H5").Value = totalOutput
wsIn.Range("H6").Value = efficiency

wsIn.Range("H6").NumberFormat = "0.00%"

End Sub

'====================================================
' RESET
'====================================================
Sub ResetSystem()

    Sheets("FL1").Cells.Clear
    Sheets("FL2").Cells.Clear

    Sheets("INPUT").Range("H2:H6").ClearContents

    Erase Segments
    SegmentCount = 0

    MsgBox "System Reset Complete"

End Sub

'====================================================
' SUPPORT FUNCTIONS
'====================================================
Function IncrementRod(ByVal rodNum As String) As String

IncrementRod = _
    Left(rodNum, 1) & _
    Format(CLng(Mid(rodNum, 2)) + 1, "00000")

End Function

Function AlphaLetter(ByVal n As Long) As String

Dim r As String

Do While n > 0

    n = n - 1

    r = Chr(65 + (n Mod 26)) & r

    n = n \ 26

Loop

AlphaLetter = r

End Function


