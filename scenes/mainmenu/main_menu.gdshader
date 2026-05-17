shader_type canvas_item;

// Captura la pantalla que queda por detrás de este nodo
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Deslizador para controlar la fuerza del desenfoque desde el inspector
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
    // Aplica el efecto difuminado
    COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);
}