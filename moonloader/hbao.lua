script_name("SARemix_HBAO")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.1.0")
local mad = require 'MoonAdditions'
local firstStart = true
local showtext = true
local timer = 0

function main()
	while true do
		wait(0)
		if isPlayerPlaying(PLAYER_HANDLE) then
			if not isCharDead(PLAYER_PED) then
				if firstStart then
					timer = os.clock()
					firstStart = false
				else
					if os.clock() - timer > 15 then
						showtext = false
					end
					--mad.draw_text(string.format("elapsed time: %.2f\n", os.clock() - timer), 10, 50, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 640, true, false, 255, 255, 255, 255, 0, 1)
				end
				if showtext then
					mad.draw_text('SA REMIX HEALTH BAR ALWAYS ON STARTED', 10, 10, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 640, true, false, 255, 255, 255, 255, 0, 1)
                else
                    mad.draw_text('.', -10, -10, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 640, false, false, 255, 255, 255, 255, 0, 1)
                end
			end
		end
	end
end