--Iba takýmto prenosom príkazu, keď sa vždy zobrazuje osd-bar, môže zobrazovanie iného textu skriptu lua a zobrazovanie textu osd počas iných operácií nezasahovať a blikať.
local osd_duration_value = mp.get_property_osd("osd-duration")
local osd_duration_value_second = osd_duration_value / 1000
local osd_bar_value = mp.get_property_osd("osd-bar")
local osd_level_value = mp.get_property_osd("osd-level")

function osdbar_show_hide_with_fullscreen(name, param)
	if param == true then
			osd_bar_show_forever:stop()
	else
	--Tento riadok má zobrazovať osd-bar okamžite po spustení, namiesto čakania na osd_duration_value_second sekundy, aby sa začalo zobrazovať stále.
			mp.command("osd-bar show-progress")
		osd_bar_show_forever = mp.add_periodic_timer( osd_duration_value_second, function()
			mp.command("osd-bar show-progress")
			osd_bar_show_forever:resume()
		end)
	end
end

if osd_bar_value ~= "no" and osd_level_value >= "1" then
--下Ďalší riadok je načítať funkciu, keď mpv prejde do stavu na celú obrazovku, a načítať funkciu, keď opúšťa stav na celú obrazovku.
	mp.observe_property("fullscreen", "bool", osdbar_show_hide_with_fullscreen)

end
