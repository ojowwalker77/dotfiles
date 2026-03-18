; =============================================================================
; Conductor LOG — severity-driven visual hierarchy
;
; Errors scream, warnings catch your eye, info reads clean,
; debug fades, trace nearly disappears. Timestamps stay quiet.
; =============================================================================

; --- Log Levels --------------------------------------------------------------

(error) @error                ; #E85A5A red — unmissable
(warn)  @warning              ; #D4A656 gold — attention
(info)  @label                ; #42BB6C green — all clear
(debug) @hint                 ; #5CC9B8 cyan italic — supplementary
(trace) @comment              ; #6B6560 gray italic — background noise

; --- Timestamps (structural scaffolding, stay out of the way) ----------------

(year_month_day) @comment.doc ; #7A746D muted
(time)           @comment.doc ; #7A746D muted

; --- Data Values -------------------------------------------------------------

(string_literal) @string      ; #D4A656 gold
(number)         @number      ; #60A5FA blue
(constant)       @type.builtin ; #AF87FF purple — true/false/null
