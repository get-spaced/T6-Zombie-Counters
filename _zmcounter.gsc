
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;

main() {
  init_dvars();
}

init() {
  level.counter_round_active = false;
  level.counter_round_started = false;

  level thread track_zombie_counter_rounds();

  onplayerconnect_callback(::on_player_connected);
}

init_dvars() {
  set_dvar_default("counter_enabled", "1");
  set_dvar_default("counter_horde_size", "24");
  set_dvar_default("counter_update_ms", "100");
  set_dvar_default("counter_bottom_offset", "42");
  set_dvar_default("counter_font_scale", "1.5");
  set_dvar_default("counter_fade_time", "0.5");
  set_dvar_default("counter_pulse_enabled", "1");
  set_dvar_default("counter_pulse_scale", "1.8");
}

on_player_connected() {
  self endon("disconnect");

  self waittill("spawned_player");

  flag_wait("initial_blackscreen_passed");

  self create_zombie_counter_hud();
  self thread update_zombie_counter();
}

set_dvar_default(name, value) {
  if (getdvar(name) != "")
    return;

  setdvar(name, value);
}

set_string_text(text) {
  if (!isdefined(text))
    text = "";

  if (isdefined(self.text) && self.text == text)
    return;

  self settextunlimited(text);
  self.text = text;
}

get_counter_font_scale() {
  scale = getdvarfloat("counter_font_scale");

  if (scale < 0.5)
    scale = 1.5;

  return scale;
}

create_zombie_counter_hud() {
  if (isdefined(self.counter_hud))
    self destroy_zombie_counter_hud();

  offset = getdvarint("counter_bottom_offset");

  if (offset < 0)
    offset = 0;

  scale = get_counter_font_scale();

  self.counter_hud = self createFontString("hudsmall", scale);
  self.counter_hud setPoint("CENTER", "BOTTOM", 0, -offset);

  self.counter_hud.color = (1, 1, 1);
  self.counter_hud.alpha = 0;
  self.counter_hud.glowAlpha = 0;
  self.counter_hud.hideWhenInMenu = 1;
  self.counter_hud.sort = 10;

  self.counter_hud set_string_text("^1Zombies: 0");

  if (level.counter_round_active && getdvarint("counter_enabled") == 1)
    self thread fade_zombie_counter(true);
}

track_zombie_counter_rounds() {
  level endon("end_game");

  for (;;) {
    level waittill("start_of_round");

    level.counter_round_active = true;
    level.counter_round_started = true;

    players = get_players();

    foreach (player in players) {
      if (!isdefined(player.counter_hud))
        continue;

      player thread fade_zombie_counter(true);
    }

    level waittill("end_of_round");

    level.counter_round_active = false;

    players = get_players();

    foreach (player in players) {
      if (!isdefined(player.counter_hud))
        continue;

      player thread fade_zombie_counter(false);
      player notify("counter_pulse_restart");
    }
  }
}

fade_zombie_counter(show) {
  self endon("disconnect");

  self notify("counter_fade_restart");
  self endon("counter_fade_restart");

  if (!isdefined(self.counter_hud))
    return;

  if (getdvarint("counter_enabled") == 0)
    show = false;

  fade_time = getdvarfloat("counter_fade_time");

  if (fade_time < 0.05)
    fade_time = 0.05;

  self.counter_hud fadeOverTime(fade_time);

  if (show)
    self.counter_hud.alpha = 1;
  else
    self.counter_hud.alpha = 0;
}

create_counter_counts() {
  counts = [];

  counts["zombies"] = 0;
  counts["dogs"] = 0;
  counts["leapers"] = 0;
  counts["witches"] = 0;

  return counts;
}

get_counter_enemy_type(enemy) {
  if (!isdefined(enemy))
    return "unknown";

  if (isdefined(enemy.isdog) && enemy.isdog)
    return "dogs";

  name = "";

  if (isdefined(enemy.targetname))
    name += " " + enemy.targetname;

  if (isdefined(enemy.animname))
    name += " " + enemy.animname;

  if (isdefined(enemy.script_noteworthy))
    name += " " + enemy.script_noteworthy;

  if (isdefined(enemy.zombie_type))
    name += " " + enemy.zombie_type;

  if (isdefined(enemy.variant_type))
    name += " " + enemy.variant_type;

  name = tolower(name);

  if (issubstr(name, "hellhound") ||
      issubstr(name, "hound") ||
      issubstr(name, "zombie_dog") ||
      issubstr(name, "dog_"))
    return "dogs";

  if (issubstr(name, "leaper") ||
      issubstr(name, "jumping_jack") ||
      issubstr(name, "minion"))
    return "leapers";

  if (issubstr(name, "witch") ||
      issubstr(name, "ghost") ||
      issubstr(name, "banshee"))
    return "witches";

  if (issubstr(name, "zombie") ||
      issubstr(name, "walker") ||
      issubstr(name, "crawler"))
    return "zombies";

  return "unknown";
}

get_counter_round_type(counts) {
  if (flag("dog_round"))
    return "dogs";

  if (isdefined(level.dog_intermission) && level.dog_intermission)
    return "dogs";

  if (counts["leapers"] > 0 &&
      counts["zombies"] == 0 &&
      counts["dogs"] == 0 &&
      counts["witches"] == 0)
    return "leapers";

  return "zombies";
}

get_zombie_counter_data() {
  data = spawnstruct();

  data.counts = create_counter_counts();
  data.active = 0;
  data.queued = 0;
  data.total = 0;
  data.hordes = 0;

  enemies = get_round_enemy_array();

  if (isdefined(enemies)) {
    foreach (enemy in enemies) {
      if (!isdefined(enemy))
        continue;

      if (!isalive(enemy))
        continue;

      type = get_counter_enemy_type(enemy);

      if (type == "unknown")
        type = "zombies";

      data.counts[type]++;
      data.active++;
    }
  }

  if (isdefined(level.zombie_total))
    data.queued = int(level.zombie_total);

  if (data.queued < 0)
    data.queued = 0;

  round_type = get_counter_round_type(data.counts);

  data.counts[round_type] += data.queued;

  data.total = data.active + data.queued;

  horde_size = getdvarint("counter_horde_size");

  if (horde_size < 1)
    horde_size = 24;

  if (data.total > 24)
    data.hordes = int((data.total + horde_size - 1) / horde_size);

  return data;
}

append_counter_part(text, count, name, color) {
  if (count <= 0)
    return text;

  if (text != "")
    text += " ^7| ";

  text += color + name + ": " + count;

  return text;
}

build_zombie_counter_text(data) {
  counts = data.counts;
  text = "";

  text = append_counter_part(text, counts["zombies"], "Zombies", "^1");
  text = append_counter_part(text, counts["dogs"], "Dogs", "^2");
  text = append_counter_part(text, counts["leapers"], "Leapers", "^3");
  text = append_counter_part(text, counts["witches"], "Witches", "^5");

  if (text == "")
    text = "^1Zombies: 0";

  if (data.total > 24)
    text += " ^7(Hordes: " + data.hordes + ")";

  return text;
}

pulse_zombie_counter() {
  self endon("disconnect");

  self notify("counter_pulse_restart");
  self endon("counter_pulse_restart");

  if (!isdefined(self.counter_hud))
    return;

  if (getdvarint("counter_pulse_enabled") == 0)
    return;

  if (!level.counter_round_active)
    return;

  if (getdvarint("counter_enabled") == 0)
    return;

  normal_scale = get_counter_font_scale();
  pulse_scale = getdvarfloat("counter_pulse_scale");

  if (pulse_scale <= normal_scale)
    pulse_scale = normal_scale + 0.2;

  self.counter_hud.fontscale = pulse_scale;

  wait 0.07;

  if (!isdefined(self.counter_hud))
    return;

  self.counter_hud.fontscale = normal_scale + ((pulse_scale - normal_scale) * 0.4);

  wait 0.07;

  if (!isdefined(self.counter_hud))
    return;

  self.counter_hud.fontscale = normal_scale;
}

update_zombie_counter() {
  self endon("disconnect");
  level endon("end_game");

  previous_text = "";
  previous_enabled = -1;
  previous_active = false;

  for (;;) {
    if (!isdefined(self.counter_hud))
      return;

    enabled = getdvarint("counter_enabled") == 1;
    active = level.counter_round_active;

    if (enabled != previous_enabled) {
      previous_enabled = enabled;

      if (!enabled)
        self thread fade_zombie_counter(false);
      else if (active)
        self thread fade_zombie_counter(true);
    }

    if (active && enabled) {
      data = get_zombie_counter_data();
      text = build_zombie_counter_text(data);

      if (text != previous_text) {
        self.counter_hud set_string_text(text);

        if (previous_text != "" && previous_active)
          self thread pulse_zombie_counter();

        previous_text = text;
      }
    } else {
      self notify("counter_pulse_restart");
      self.counter_hud.fontscale = get_counter_font_scale();
    }

    previous_active = active;

    update_ms = getdvarint("counter_update_ms");

    if (update_ms < 50)
      update_ms = 50;

    wait(update_ms / 1000.0);
  }
}

destroy_zombie_counter_hud() {
  self notify("counter_pulse_restart");
  self notify("counter_fade_restart");

  if (!isdefined(self.counter_hud))
    return;

  self.counter_hud destroy();
  self.counter_hud = undefined;
}