### DECP E2E API Tests ###
# This script tests all endpoints through the API Gateway (port 8080)
# Requires: $STUDENT_TOKEN, $ALUMNI_TOKEN, $ADMIN_TOKEN set in the shell

param(
    [string]$StudentToken,
    [string]$AlumniToken,
    [string]$AdminToken
)

$GW = "http://localhost:8080"
$pass = 0; $fail = 0; $issues = @()

function Test-Endpoint {
    param([string]$Name, [string]$Method, [string]$Url, [string]$Token, [string]$Body, [int[]]$ExpectedCodes = @(200))
    
    $args = @("-s", "-o", "NUL", "-w", "%{http_code}", "-X", $Method, $Url)
    if ($Token) { $args += @("-H", "Authorization: Bearer $Token") }
    if ($Body) { $args += @("-H", "Content-Type: application/json", "-d", $Body) }
    
    $code = curl.exe @args
    $ok = $ExpectedCodes -contains [int]$code
    $status = if ($ok) { "PASS" } else { "FAIL" }
    
    if ($ok) { $script:pass++ } else { $script:fail++; $script:issues += "$Name -> HTTP $code (expected $($ExpectedCodes -join '|'))" }
    Write-Host "$status [$code] $Name"
    return $code
}

function Test-EndpointBody {
    param([string]$Name, [string]$Method, [string]$Url, [string]$Token, [string]$Body, [int[]]$ExpectedCodes = @(200))
    
    $args = @("-s", "-w", "`n%{http_code}", "-X", $Method, $Url)
    if ($Token) { $args += @("-H", "Authorization: Bearer $Token") }
    if ($Body) { $args += @("-H", "Content-Type: application/json", "-d", $Body) }
    
    $raw = curl.exe @args
    $lines = $raw -split "`n"
    $code = $lines[-1].Trim()
    $body = ($lines[0..($lines.Length-2)] -join "`n").Trim()
    $ok = $ExpectedCodes -contains [int]$code
    $status = if ($ok) { "PASS" } else { "FAIL" }
    
    if ($ok) { $script:pass++ } else { $script:fail++; $script:issues += "$Name -> HTTP $code (expected $($ExpectedCodes -join '|'))" }
    Write-Host "$status [$code] $Name"
    return $body
}

Write-Host "================================================================"
Write-Host "  DECP Microservices - E2E Endpoint Tests"
Write-Host "  Gateway: $GW"
Write-Host "================================================================"
Write-Host ""

# ========== AUTH SERVICE ==========
Write-Host "--- AUTH SERVICE (via Gateway) ---"
Test-Endpoint "Auth: GET /api/auth/test" "GET" "$GW/api/auth/test" "" "" @(200)
Test-Endpoint "Auth: POST /api/auth/login (valid)" "POST" "$GW/api/auth/login" "" '@{"username":"e2estudent","password":"E2ePass1!"}' @(200)
Test-Endpoint "Auth: POST /api/auth/login (invalid)" "POST" "$GW/api/auth/login" "" '@{"username":"e2estudent","password":"wrong"}' @(500, 401)
Test-Endpoint "Auth: GET /api/auth/validate (valid)" "GET" "$GW/api/auth/validate?token=$StudentToken" "" "" @(200)
Test-Endpoint "Auth: GET /api/auth/validate (invalid)" "GET" "$GW/api/auth/validate?token=invalidtoken" "" "" @(401)
Write-Host ""

# ========== USER SERVICE ==========
Write-Host "--- USER SERVICE ---"
Test-Endpoint "User: GET /api/users/12 (with token)" "GET" "$GW/api/users/12" $StudentToken "" @(200)
Test-Endpoint "User: GET /api/users/search?username=e2estudent" "GET" "$GW/api/users/search?username=e2estudent" $StudentToken "" @(200)
Test-Endpoint "User: GET /api/users/alumni" "GET" "$GW/api/users/alumni" $StudentToken "" @(200)
Test-Endpoint "User: GET /api/users/12 (no token)" "GET" "$GW/api/users/12" "" "" @(401)
Write-Host ""

# ========== POST SERVICE ==========
Write-Host "--- POST SERVICE ---"
$postBody = '{"userId":12,"fullName":"E2E Student","content":"Hello from E2E test!","mediaUrls":[]}'
$postResult = Test-EndpointBody "Post: POST /api/posts (create)" "POST" "$GW/api/posts" $StudentToken $postBody @(200)
Test-Endpoint "Post: GET /api/posts (list)" "GET" "$GW/api/posts" $StudentToken "" @(200)
# Try to extract post ID for subsequent tests
try { $postId = ($postResult | ConvertFrom-Json).id; Write-Host "  Created post ID: $postId" } catch { $postId = $null }
if ($postId) {
    Test-Endpoint "Post: POST /api/posts/$postId/like" "POST" "$GW/api/posts/$postId/like" $StudentToken '{"userId":12}' @(200)
    $commentBody = '{"userId":12,"username":"e2estudent","content":"Test comment"}'
    Test-Endpoint "Post: POST /api/posts/$postId/comment" "POST" "$GW/api/posts/$postId/comment" $StudentToken $commentBody @(200)
}
Write-Host ""

# ========== JOB SERVICE ==========
Write-Host "--- JOB SERVICE ---"
$jobBody = '{"title":"Test Job","description":"E2E test job","company":"Test Corp","location":"Remote","salary":"50000","type":"FULL_TIME","postedBy":13}'
$jobResult = Test-EndpointBody "Job: POST /api/jobs (alumni create)" "POST" "$GW/api/jobs" $AlumniToken $jobBody @(200)
Test-Endpoint "Job: GET /api/jobs (list)" "GET" "$GW/api/jobs" $StudentToken "" @(200)
try { $jobId = ($jobResult | ConvertFrom-Json).id; Write-Host "  Created job ID: $jobId" } catch { $jobId = $null }
if ($jobId) {
    Test-Endpoint "Job: GET /api/jobs/$jobId" "GET" "$GW/api/jobs/$jobId" $StudentToken "" @(200)
    $appBody = '{"userId":12,"coverLetter":"I want this job","resumeUrl":"http://example.com/resume.pdf"}'
    Test-Endpoint "Job: POST /api/jobs/$jobId/apply (student)" "POST" "$GW/api/jobs/$jobId/apply" $StudentToken $appBody @(200)
    Test-Endpoint "Job: GET /api/jobs/$jobId/applications" "GET" "$GW/api/jobs/$jobId/applications" $AlumniToken "" @(200)
    Test-Endpoint "Job: GET /api/jobs/user/12/applications" "GET" "$GW/api/jobs/user/12/applications" $StudentToken "" @(200)
}
Test-Endpoint "Job: POST /api/jobs (student forbidden)" "POST" "$GW/api/jobs" $StudentToken $jobBody @(403)
Write-Host ""

# ========== EVENT SERVICE ==========
Write-Host "--- EVENT SERVICE ---"
$eventBody = '{"title":"Test Event","description":"E2E test event","location":"Online","startTime":"2026-04-01T10:00:00","endTime":"2026-04-01T12:00:00","maxAttendees":100}'
$eventResult = Test-EndpointBody "Event: POST /api/events (alumni)" "POST" "$GW/api/events" $AlumniToken $eventBody @(200)
Test-Endpoint "Event: GET /api/events (list)" "GET" "$GW/api/events" $StudentToken "" @(200)
Test-Endpoint "Event: GET /api/events/upcoming" "GET" "$GW/api/events/upcoming" $StudentToken "" @(200)
try { $eventId = ($eventResult | ConvertFrom-Json).id; Write-Host "  Created event ID: $eventId" } catch { $eventId = $null }
if ($eventId) {
    Test-Endpoint "Event: GET /api/events/$eventId" "GET" "$GW/api/events/$eventId" $StudentToken "" @(200)
    $rsvpBody = '{"status":"ATTENDING"}'
    Test-Endpoint "Event: POST /api/events/$eventId/rsvp" "POST" "$GW/api/events/$eventId/rsvp" $StudentToken $rsvpBody @(200)
    Test-Endpoint "Event: GET /api/events/$eventId/attendees" "GET" "$GW/api/events/$eventId/attendees" $StudentToken "" @(200)
}
Test-Endpoint "Event: POST /api/events (student forbidden)" "POST" "$GW/api/events" $StudentToken $eventBody @(403)
Write-Host ""

# ========== RESEARCH SERVICE ==========
Write-Host "--- RESEARCH SERVICE ---"
$researchBody = '{"title":"Test Research","abstract":"E2E test abstract","authors":["E2E Alumni"],"category":"JOURNAL_ARTICLE","tags":["AI"],"fileUrl":"http://example.com/paper.pdf","userId":13}'
$researchResult = Test-EndpointBody "Research: POST /api/research (alumni)" "POST" "$GW/api/research" $AlumniToken $researchBody @(200)
Test-Endpoint "Research: GET /api/research (list)" "GET" "$GW/api/research" $StudentToken "" @(200)
try { $researchId = ($researchResult | ConvertFrom-Json).id; Write-Host "  Created research ID: $researchId" } catch { $researchId = $null }
if ($researchId) {
    Test-Endpoint "Research: GET /api/research/$researchId" "GET" "$GW/api/research/$researchId" $StudentToken "" @(200)
    Test-Endpoint "Research: GET /api/research/user/13" "GET" "$GW/api/research/user/13" $StudentToken "" @(200)
    Test-Endpoint "Research: POST /api/research/$researchId/download" "POST" "$GW/api/research/$researchId/download" $StudentToken "" @(200)
    Test-Endpoint "Research: POST /api/research/$researchId/cite" "POST" "$GW/api/research/$researchId/cite" $StudentToken "" @(200)
}
Write-Host ""

# ========== MESSAGING SERVICE ==========
Write-Host "--- MESSAGING SERVICE ---"
$convBody = '{"participantIds":[12,13],"name":"Test Conversation"}'
$convResult = Test-EndpointBody "Messaging: POST /api/conversations" "POST" "$GW/api/conversations" $StudentToken $convBody @(200)
Test-Endpoint "Messaging: GET /api/conversations" "GET" "$GW/api/conversations" $StudentToken "" @(200)
try { $convId = ($convResult | ConvertFrom-Json).id; Write-Host "  Created conversation ID: $convId" } catch { $convId = $null }
if ($convId) {
    Test-Endpoint "Messaging: GET /api/conversations/$convId" "GET" "$GW/api/conversations/$convId" $StudentToken "" @(200)
    Test-Endpoint "Messaging: GET /api/conversations/$convId/messages" "GET" "$GW/api/conversations/$convId/messages" $StudentToken "" @(200)
    Test-Endpoint "Messaging: PUT /api/conversations/$convId/read" "PUT" "$GW/api/conversations/$convId/read" $StudentToken "" @(200)
}
Write-Host ""

# ========== NOTIFICATION SERVICE ==========
Write-Host "--- NOTIFICATION SERVICE ---"
Test-Endpoint "Notification: GET /api/notifications" "GET" "$GW/api/notifications" $StudentToken "" @(200)
Test-Endpoint "Notification: GET /api/notifications/unread-count" "GET" "$GW/api/notifications/unread-count" $StudentToken "" @(200)
Test-Endpoint "Notification: PUT /api/notifications/read-all" "PUT" "$GW/api/notifications/read-all" $StudentToken "" @(200, 204)
Write-Host ""

# ========== ANALYTICS SERVICE ==========
Write-Host "--- ANALYTICS SERVICE ---"
Test-Endpoint "Analytics: GET /api/analytics/overview (admin)" "GET" "$GW/api/analytics/overview" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/users" "GET" "$GW/api/analytics/users" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/posts" "GET" "$GW/api/analytics/posts" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/jobs" "GET" "$GW/api/analytics/jobs" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/events" "GET" "$GW/api/analytics/events" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/research" "GET" "$GW/api/analytics/research" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/messages" "GET" "$GW/api/analytics/messages" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/timeline" "GET" "$GW/api/analytics/timeline?from=2026-01-01&to=2026-12-31" $AdminToken "" @(200)
Test-Endpoint "Analytics: GET /api/analytics/overview (student denied)" "GET" "$GW/api/analytics/overview" $StudentToken "" @(403, 500)
Write-Host ""

# ========== MENTORSHIP SERVICE ==========
Write-Host "--- MENTORSHIP SERVICE ---"
$mentorProfileBody = '{"bio":"E2E mentor","expertise":["Java","Spring"],"availability":"WEEKLY","department":"CS"}'
Test-Endpoint "Mentorship: POST /api/mentorship/profile (alumni)" "POST" "$GW/api/mentorship/profile" $AlumniToken $mentorProfileBody @(200)
$menteeProfileBody = '{"bio":"E2E mentee","interests":["Java"],"availability":"WEEKLY","department":"CS"}'
Test-Endpoint "Mentorship: POST /api/mentorship/profile (student)" "POST" "$GW/api/mentorship/profile" $StudentToken $menteeProfileBody @(200)
Test-Endpoint "Mentorship: GET /api/mentorship/profile (own)" "GET" "$GW/api/mentorship/profile" $StudentToken "" @(200)
Test-Endpoint "Mentorship: GET /api/mentorship/profile/13" "GET" "$GW/api/mentorship/profile/13" $StudentToken "" @(200)
Test-Endpoint "Mentorship: GET /api/mentorship/matches" "GET" "$GW/api/mentorship/matches" $StudentToken "" @(200)
$mentorReqBody = '{"mentorId":13,"message":"I would like mentorship"}'
Test-Endpoint "Mentorship: POST /api/mentorship/request (student)" "POST" "$GW/api/mentorship/request" $StudentToken $mentorReqBody @(200)
Test-Endpoint "Mentorship: GET /api/mentorship/requests" "GET" "$GW/api/mentorship/requests" $StudentToken "" @(200)
Test-Endpoint "Mentorship: GET /api/mentorship/relationships" "GET" "$GW/api/mentorship/relationships" $StudentToken "" @(200)
Write-Host ""

# ========== SUMMARY ==========
Write-Host "================================================================"
Write-Host "  RESULTS: $pass PASSED, $fail FAILED"
Write-Host "================================================================"
if ($issues.Count -gt 0) {
    Write-Host ""
    Write-Host "FAILED TESTS:"
    $issues | ForEach-Object { Write-Host "  - $_" }
}
