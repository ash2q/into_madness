# Into Madness

You descend into The Realm. Endless floor after endless floor, there is loot to be discovered and enemies to slay. Your sanity may be harder to keep a handle on than would be expected. Choose your battles carefully and keep in mind that sometimes you're having an unlucky 

# Controls

* arrow keys -- move
* X -- attack
* Z (hold while not moving) -- action menu (press arrow key to select action)
* Z+X -- parry attack


# Stat Rework

The idea here is to have several stats but not so many that you can't keep up. Each stat should have a clear "if I focus on this, it could be a really good thing". 

* PATK -- physical attack damage.
* PDEF -- physical damage reduction/defense
* AGLT -- agility. How fast ENG is recharged, walk speed
* FOCS -- focus. How fast CLR is recharged, parry damage
* LUCK -- luck.

# Player Aspects

The player has 3 "aspects". Each aspect is like a different party member and if one aspect "dies" then it will switch to a different aspect. 
There's three aspects. The first 2 are provided from game start and are freely swappable

1. FIGHT --optimized for DPS, faster ENG generation. normal CLR generation but only when not attacking
2. REACT --optimized for actions, faster CLR generation. Slow ENG generation, can parry
3. BREAK --caused by low sanity, ???

# Moves And Actions

Moves are considered to be quick reflex like movements, which can be done rapidly and only cost ENG. Actions are considered to be more methodical and careful decisions made in response to a situation. 

Moves are used by the FIGHT aspect, while actions are used by the REACT aspect. 

Armor and weapons always include at least one move and one action. 

# Game Notes

This is just a place to write out some notes, reading them would be helpful for devs of the game, but also to players as well..

## Stats

* PATK -- physical attack, damage of physical attacks
* MATK -- magical attack, damage of magical attacks
* PSPD -- physical attack speed, how fast you can use your physical weapons
* MSPD -- magical attack speed, how fast your magical
* PDEF -- physical defense, reduction of incoming physical damage
* MDEF -- magical defense, reduction of incoming magic damage
* MSPD -- movement speed
* ABLT -- ability effectiveness

All stats are based on totals. A weapon with a high stat total can typically be assumed to be good in some way, though maybe not always the ideal way for using the weapon itself.

## HUD

The hud displays several things.
* Your primary attack weapon
* The status etc of your secondary attack weapon
* The charge status of your ability
* The sanity meter
* The charge status of using an action (ACT)
* The charge status of using a move (MOV)

## Equips, Moves, and Actions

There's two different things that can be used in battle, moves and actions. 

Moves are moderated by PSPD or MSPD, depending on if the equip for that button press is a (P) physical or (M)magical item. Moves are typically fairly fast to execute and recharge within a reasonable time as well. 

The controller layout during combat is planned as so:

* X -- primary move
* Z -- secondary move
* Z+X -- flip to strat mode

When in strat mode, the controls are as so:

* X -- primary move (not necessarily the same action as the other mode)
* Z -- action menu
* Z+X -- flip to attack mode

In the menu

Within the menu, X is confirm and Z is to go back (or exit).

In the dungeon, the controller layout is:

* Z -- gear and equip menu
* X -- item menu

Gear must be equipped to use them, but provide a selection of moves and actions, depending on the gear. Most weapons have 3 moves and/or actions in total. Most armor pieces have 1 action

If the same action is provided from multiple pieces of gear, the action is improved. The same move provided from gear does not stack or offer any improvement.

## Parry

There is a unique parry mechanic. It is triggered by using your primary attack at the exact time a bullet hits the player. If the parry is successful then your primary move is recharged, you take no damage for several seconds, and the enemy which did the attack takes some damage. If the parry was attempted but unsuccessful (too slow or too fast) then the move charge is consumed and damage taken is increased. Parrying is only an available option if you have a move you can use (enough energy). 

Failing a parry has an effect on sanity. Enemies can also parry attacks from the player, using the luck stat. When the player's attack is parried the amount of damage the attack would've done is returned to the player as damage. Most enemies are expected to have very low luck stats so that this is very improbable, but certain side bosses may require the player going against a lucky advesary. The specific strategy best would be to have good attacks but not too good that could one-shot the player.

As sanity decreases, the typical visuals for parrying begin to become less and less precise or not appearing at all


