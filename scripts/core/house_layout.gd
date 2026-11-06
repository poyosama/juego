class_name HouseLayout
extends RefCounted
## Define la estructura de datos espacial y lógica de la casa de dos pisos.

static func get_default_layout() -> Dictionary:
	return {
		"player_spawn": Vector3(0.0, 0.5, 3.0),
		"enemy_spawn": Vector3(6.0, 0.5, -6.0),
		"main_exit": {
			"position": Vector3(0.0, 1.2, 5.0),
			"size": Vector3(2.0, 2.4, 0.3)
		},
		"fuse_box": {
			"id": "fusebox_main",
			"position": Vector3(-5.8, 1.2, -5.8)
		},
		# Llaves en el mapa
		"keys": [
			{
				"id": "llave_habitacion_principal",
				"name": "Llave Habitación Principal",
				"position": Vector3(5.5, 3.8, 2.5) # en habitacion de huespedes (planta alta)
			},
			{
				"id": "llave_sotano",
				"name": "Llave del Sótano",
				"position": Vector3(-5.5, 3.8, 3.5) # en habitacion principal (planta alta)
			}
		],
		# Exactamente 5 fusibles
		"fuses": [
			{
				"id": "fuse_1",
				"name": "Fusible 10A",
				"position": Vector3(5.2, 0.5, 3.2) # Cocina (PB)
			},
			{
				"id": "fuse_2",
				"name": "Fusible 15A",
				"position": Vector3(-5.2, 0.5, -3.2) # Sótano (PB, tras puerta de sótano)
			},
			{
				"id": "fuse_3",
				"name": "Fusible 20A",
				"position": Vector3(1.5, 4.0, -4.5) # Baño (Piso 1)
			},
			{
				"id": "fuse_4",
				"name": "Fusible 25A",
				"position": Vector3(5.2, 4.0, -2.5) # Habitación de huéspedes (Piso 1)
			},
			{
				"id": "fuse_5",
				"name": "Fusible 30A",
				"position": Vector3(-4.8, 4.0, 1.5) # Habitación principal (Piso 1)
			}
		],
		# Puertas
		"doors": [
			{
				"id": "door_kitchen",
				"name": "Puerta Cocina",
				"position": Vector3(2.5, 1.1, 1.0),
				"rotation_y": 0.0,
				"is_locked": false,
				"required_key": ""
			},
			{
				"id": "door_basement",
				"name": "Puerta Sótano",
				"position": Vector3(-2.5, 1.1, -2.0),
				"rotation_y": 0.0,
				"is_locked": true,
				"required_key": "llave_sotano"
			},
			{
				"id": "door_guest_room",
				"name": "Puerta Huéspedes",
				"position": Vector3(2.5, 4.6, 0.0),
				"rotation_y": 0.0,
				"is_locked": false,
				"required_key": ""
			},
			{
				"id": "door_master_room",
				"name": "Puerta Principal",
				"position": Vector3(-2.5, 4.6, 0.0),
				"rotation_y": 0.0,
				"is_locked": true,
				"required_key": "llave_habitacion_principal"
			}
		],
		# Escondites
		"hiding_spots": [
			{
				"id": "closet_pb",
				"name": "Armario del Comedor",
				"position": Vector3(6.0, 1.0, -1.0),
				"exit_position": Vector3(4.8, 0.5, -1.0)
			},
			{
				"id": "bed_guests",
				"name": "Debajo de la Cama",
				"position": Vector3(5.0, 3.8, 4.0),
				"exit_position": Vector3(4.0, 3.8, 4.0)
			},
			{
				"id": "closet_master",
				"name": "Armario Dormitorio",
				"position": Vector3(-6.0, 4.5, 2.0),
				"exit_position": Vector3(-4.8, 3.8, 2.0)
			}
		],
		# Contestadores con mensajes de voz
		"answering_machines": [
			{
				"id": "machine_living",
				"name": "Contestador Sala",
				"position": Vector3(1.5, 0.8, 4.0),
				"subtitles": [
					{"time": 0.0, "text": "[Bip del contestador...]"},
					{"time": 2.0, "text": "Mensaje 1 (14 de Octubre):"},
					{"time": 4.5, "text": "'Mamá, no te quedes en esa casa.'"},
					{"time": 7.5, "text": "'Las luces se cortaron otra vez... no estás sola.'"},
					{"time": 11.0, "text": "'Cambié la llave de la habitación de arriba. Salí ya.'"}
				]
			},
			{
				"id": "machine_bathroom",
				"name": "Radio del Baño",
				"position": Vector3(2.0, 4.2, -5.0),
				"subtitles": [
					{"time": 0.0, "text": "[Interferencia estática... siseo de cinta...]"},
					{"time": 2.5, "text": "Voz entrecortada:"},
					{"time": 5.0, "text": "'...escuché algo rascando las paredes del sótano...'"},
					{"time": 9.0, "text": "'...dejé la llave del sótano guardada en la habitación principal...'"}
				]
			},
			{
				"id": "machine_master",
				"name": "Contestador Principal",
				"position": Vector3(-5.0, 4.2, 4.0),
				"subtitles": [
					{"time": 0.0, "text": "[Tono continuo... clic]"},
					{"time": 2.5, "text": "'Si encontrás los 5 fusibles, ponelos en la caja del sótano.'"},
					{"time": 7.0, "text": "'Eso devolverá la corriente al cerrojo eléctrico de la puerta de salida.'"},
					{"time": 11.5, "text": "'¡Corré hacia afuera! ¡No te detengas!'"}
				]
			}
		],
		# Puntos de patrulla para el enemigo
		"patrol_points": [
			Vector3(0.0, 0.5, 2.0),   # Hall PB
			Vector3(5.0, 0.5, 2.0),   # Cocina PB
			Vector3(-4.5, 0.5, -4.0), # Entrada al sótano
			Vector3(0.0, 4.0, 0.0),   # Pasillo Planta Alta
			Vector3(4.5, 4.0, 2.5),   # Habitación huéspedes
			Vector3(-4.5, 4.0, 2.5)   # Habitación principal
		],
		# Sustos por zonas
		"scare_triggers": [
			{
				"id": "scare_hall_light",
				"position": Vector3(0.0, 1.0, -1.0),
				"size": Vector3(2.5, 2.0, 2.0),
				"type": "flicker_and_noise"
			},
			{
				"id": "scare_bathroom_creak",
				"position": Vector3(1.5, 4.2, -3.5),
				"size": Vector3(2.0, 2.0, 2.0),
				"type": "creak_door"
			}
		]
	}
