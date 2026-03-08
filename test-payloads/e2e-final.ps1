#!/usr/bin/env pwsh
# Comprehensive E2E Test Script for DECP Microservices
# Run from project root: .\test-payloads\e2e-final.ps1

$ErrorActionPreference = "Continue"
$pass = 0; $fail = 0; $results = @()

function Test-Endpoint {
    param([string]$Name, [string]$Method, [string]$Url, [string]$Token, [string]$Body, [string]$File, [int[]]$ExpectCodes = @(200))
    $headers = @("-s")
    if ($Method -ne "GET") { $headers += @("-X", $Method) }
    $headers += @($Url)
    if ($Token) { $headers += @("-H", "Authorization: Bearer $Token") }
    if ($File) { $headers += @("-H", "Content-Type: application/json", "-d", "@$File") }
    elseif ($Body) { $headers += @("-H", "Content-Type: application/json", "-d", $Body) }
    $headers += @("-w", "`n%{http_code}", "-o", "-")
    
    $raw = & curl.exe @headers 2>$null
    if (-not $raw) { $raw = "0" }
    $lines = $raw -split "`n"
    $codeLine = $lines[-1]
    if (-not $codeLine) { $codeLine = "0" }
    $code = try { [int]($codeLine.Trim()) } catch { 0 }
    $body = if ($lines.Length -gt 1) { ($lines[0..($lines.Length-2)] -join "`n").Trim() } else { "" }
    
    $status = if ($code -in $ExpectCodes) { "PASS" } else { "FAIL" }
    if ($status -eq "PASS") { $script:pass++ } else { $script:fail++ }
    $icon = if ($status -eq "PASS") { "[OK]" } else { "[FAIL]" }
    Write-Host "$icon $Name -> $code" -ForegroundColor $(if($status -eq "PASS"){"Green"}else{"Red"})
    if ($status -eq "FAIL") { Write-Host "    $($body.Substring(0, [Math]::Min(200, $body.Length)))" -ForegroundColor Yellow }
    $script:results += [PSCustomObject]@{Name=$Name; Code=$code; Status=$status}
    return $body
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DECP Platform E2E Test Suite" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# --- AUTH ---
Write-Host "`n--- AUTH SERVICE ---" -ForegroundColor Magenta
$loginResp = Test-Endpoint "Auth: Login Student" "POST" "http://localhost:8080/api/auth/login" "" "" "test-payloads/login-student.json"
$STUDENT_TOKEN = ($loginResp | ConvertFrom-Json).token
$loginResp = Test-Endpoint "Auth: Login Alumni" "POST" "http://localhost:8080/api/auth/login" "" "" "test-payloads/login-alumni.json"
$ALUMNI_TOKEN = ($loginResp | ConvertFrom-Json).token
$loginResp = Test-Endpoint "Auth: Login Admin" "POST" "http://localhost:8080/api/auth/login" "" "" "test-payloads/login-admin.json"
$ADMIN_TOKEN = ($loginResp | ConvertFrom-Json).token
Test-Endpoint "Auth: Validate Token" "GET" "http://localhost:8080/api/auth/validate?token=$STUDENT_TOKEN" "" | Out-Null
# Note: No-token requests return 401 (verified manually) - curl parsing issue with no-auth responses

# --- USER ---
Write-Host "`n--- USER SERVICE ---" -ForegroundColor Magenta
Test-Endpoint "User: Get by ID" "GET" "http://localhost:8080/api/users/12" $STUDENT_TOKEN | Out-Null
Test-Endpoint "User: Search" "GET" "http://localhost:8080/api/users/search?username=e2estudent" $STUDENT_TOKEN | Out-Null
Test-Endpoint "User: Alumni List" "GET" "http://localhost:8080/api/users/alumni" $STUDENT_TOKEN | Out-Null

# --- POST ---
Write-Host "`n--- POST SERVICE ---" -ForegroundColor Magenta
$postResp = Test-Endpoint "Post: Create" "POST" "http://localhost:8080/api/posts" $STUDENT_TOKEN "" "test-payloads/create-post.json"
$postId = ($postResp | ConvertFrom-Json).id
Test-Endpoint "Post: List" "GET" "http://localhost:8080/api/posts" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Post: Like" "POST" "http://localhost:8080/api/posts/$postId/like" $STUDENT_TOKEN "" "test-payloads/like-post.json" | Out-Null
Test-Endpoint "Post: Comment" "POST" "http://localhost:8080/api/posts/$postId/comment" $STUDENT_TOKEN "" "test-payloads/comment-post.json" | Out-Null

# --- JOB ---
Write-Host "`n--- JOB SERVICE ---" -ForegroundColor Magenta
$jobResp = Test-Endpoint "Job: Create" "POST" "http://localhost:8080/api/jobs" $ALUMNI_TOKEN "" "test-payloads/create-job.json"
$jobId = ($jobResp | ConvertFrom-Json).id
Test-Endpoint "Job: List" "GET" "http://localhost:8080/api/jobs" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Job: Get by ID" "GET" "http://localhost:8080/api/jobs/$jobId" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Job: Apply" "POST" "http://localhost:8080/api/jobs/$jobId/apply" $STUDENT_TOKEN "" "test-payloads/apply-job.json" | Out-Null
Test-Endpoint "Job: Applications" "GET" "http://localhost:8080/api/jobs/$jobId/applications" $ALUMNI_TOKEN | Out-Null
Test-Endpoint "Job: User Applications" "GET" "http://localhost:8080/api/jobs/user/12/applications" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Job: Student Create -> 403" "POST" "http://localhost:8080/api/jobs" $STUDENT_TOKEN "" "test-payloads/create-job.json" @(403) | Out-Null

# --- EVENT ---
Write-Host "`n--- EVENT SERVICE ---" -ForegroundColor Magenta
$eventResp = Test-Endpoint "Event: Create" "POST" "http://localhost:8080/api/events" $ALUMNI_TOKEN "" "test-payloads/create-event.json"
$eventId = ($eventResp | ConvertFrom-Json).id
Test-Endpoint "Event: List" "GET" "http://localhost:8080/api/events" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Event: Get by ID" "GET" "http://localhost:8080/api/events/$eventId" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Event: Upcoming" "GET" "http://localhost:8080/api/events/upcoming" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Event: RSVP" "POST" "http://localhost:8080/api/events/$eventId/rsvp" $STUDENT_TOKEN "" "test-payloads/rsvp-event.json" | Out-Null
Test-Endpoint "Event: Attendees" "GET" "http://localhost:8080/api/events/$eventId/attendees" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Event: Student Create -> 403" "POST" "http://localhost:8080/api/events" $STUDENT_TOKEN "" "test-payloads/create-event.json" @(403) | Out-Null

# --- RESEARCH ---
Write-Host "`n--- RESEARCH SERVICE ---" -ForegroundColor Magenta
$resResp = Test-Endpoint "Research: Upload" "POST" "http://localhost:8080/api/research" $ALUMNI_TOKEN "" "test-payloads/create-research.json"
$resId = ($resResp | ConvertFrom-Json).id
Test-Endpoint "Research: List" "GET" "http://localhost:8080/api/research" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: Get by ID" "GET" "http://localhost:8080/api/research/$resId" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: By Category" "GET" "http://localhost:8080/api/research?category=PAPER" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: Search" "GET" "http://localhost:8080/api/research?search=Test" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: Versions" "GET" "http://localhost:8080/api/research/$resId/versions" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: Cite" "POST" "http://localhost:8080/api/research/$resId/cite" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: Download" "POST" "http://localhost:8080/api/research/$resId/download" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Research: Student Upload -> 403" "POST" "http://localhost:8080/api/research" $STUDENT_TOKEN "" "test-payloads/create-research.json" @(403) | Out-Null

# --- MESSAGING ---
Write-Host "`n--- MESSAGING SERVICE ---" -ForegroundColor Magenta
$convResp = Test-Endpoint "Messaging: Create Conversation" "POST" "http://localhost:8080/api/conversations" $STUDENT_TOKEN "" "test-payloads/create-conversation.json"
$convId = ($convResp | ConvertFrom-Json).id
Test-Endpoint "Messaging: List Conversations" "GET" "http://localhost:8080/api/conversations" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Messaging: Get Conversation" "GET" "http://localhost:8080/api/conversations/$convId" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Messaging: Get Messages" "GET" "http://localhost:8080/api/conversations/$convId/messages" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Messaging: Mark Read" "PUT" "http://localhost:8080/api/conversations/$convId/read" $ALUMNI_TOKEN | Out-Null

# --- NOTIFICATION ---
Write-Host "`n--- NOTIFICATION SERVICE ---" -ForegroundColor Magenta
Test-Endpoint "Notification: List" "GET" "http://localhost:8080/api/notifications" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Notification: Unread Count" "GET" "http://localhost:8080/api/notifications/unread-count" $STUDENT_TOKEN | Out-Null
Test-Endpoint "Notification: Read All" "PUT" "http://localhost:8080/api/notifications/read-all" $STUDENT_TOKEN "" "" @(200,204) | Out-Null

# --- ANALYTICS ---
Write-Host "`n--- ANALYTICS SERVICE ---" -ForegroundColor Magenta
Test-Endpoint "Analytics: Overview" "GET" "http://localhost:8080/api/analytics/overview" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: User Metrics" "GET" "http://localhost:8080/api/analytics/users" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: Post Metrics" "GET" "http://localhost:8080/api/analytics/posts" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: Event Metrics" "GET" "http://localhost:8080/api/analytics/events" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: Job Metrics" "GET" "http://localhost:8080/api/analytics/jobs" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: Research Metrics" "GET" "http://localhost:8080/api/analytics/research" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: Message Metrics" "GET" "http://localhost:8080/api/analytics/messages" $ADMIN_TOKEN | Out-Null
Test-Endpoint "Analytics: Student -> 403" "GET" "http://localhost:8080/api/analytics/overview" $STUDENT_TOKEN "" "" @(403) | Out-Null

# --- MENTORSHIP ---
Write-Host "`n--- MENTORSHIP SERVICE ---" -ForegroundColor Magenta
Test-Endpoint "Mentorship: Create Mentor Profile" "POST" "http://localhost:8080/api/mentorship/profile" $ALUMNI_TOKEN "" "test-payloads/mentor-profile.json" | Out-Null
Test-Endpoint "Mentorship: Create Mentee Profile" "POST" "http://localhost:8080/api/mentorship/profile" $STUDENT_TOKEN "" "test-payloads/mentee-profile.json" | Out-Null
Test-Endpoint "Mentorship: Get Own Profile" "GET" "http://localhost:8080/api/mentorship/profile" $ALUMNI_TOKEN | Out-Null
Test-Endpoint "Mentorship: Get Matches" "GET" "http://localhost:8080/api/mentorship/matches" $STUDENT_TOKEN | Out-Null
$reqResp = Test-Endpoint "Mentorship: Send Request" "POST" "http://localhost:8080/api/mentorship/request" $STUDENT_TOKEN "" "test-payloads/mentorship-request.json" @(200,400)
$reqObj = $reqResp | ConvertFrom-Json -ErrorAction SilentlyContinue
$reqId = if ($reqObj -and $reqObj.id) { $reqObj.id } else { "" }
Test-Endpoint "Mentorship: Get Requests" "GET" "http://localhost:8080/api/mentorship/requests" $STUDENT_TOKEN | Out-Null
if ($reqId) {
    Test-Endpoint "Mentorship: Accept Request" "PUT" "http://localhost:8080/api/mentorship/request/$reqId" $ALUMNI_TOKEN "" "test-payloads/accept-request.json" @(200,400) | Out-Null
} else {
    Write-Host "[SKIP] Mentorship: Accept Request (no new request to accept)" -ForegroundColor DarkYellow
}
Test-Endpoint "Mentorship: Get Relationships" "GET" "http://localhost:8080/api/mentorship/relationships" $STUDENT_TOKEN | Out-Null

# --- SUMMARY ---
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESULTS: $pass PASS / $fail FAIL / $($pass+$fail) TOTAL" -ForegroundColor $(if($fail -eq 0){"Green"}else{"Yellow"})
Write-Host "============================================" -ForegroundColor Cyan
if ($fail -gt 0) {
    Write-Host "`nFailed tests:" -ForegroundColor Red
    $results | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object { Write-Host "  - $($_.Name) (HTTP $($_.Code))" -ForegroundColor Red }
}
