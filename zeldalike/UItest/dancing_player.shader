shader_type canvas_item;

uniform float time_factor = .8;
uniform vec2 amplitude = vec2(10.0, 5.0);

void vertex() {
//	VERTEX = VERTEX + sin(TIME) * vec2(0, 10.0) + cos(TIME) * vec2(10.0, 0);
	
	//Adding vertex.x,y back in adds randomness
	
	VERTEX.x += cos(TIME * time_factor + VERTEX.x + VERTEX.y) * amplitude.x;
	VERTEX.y += sin(TIME * time_factor + VERTEX.y + VERTEX.x) * amplitude.y;
	}