
attribute mediump vec4 attr_pos;
attribute mediump vec2 attr_uv;
uniform  highp mat4 unif_cammat4;

varying mediump vec2 vary_uv;

void main()
{
    gl_Position = unif_cammat4 * attr_pos ;
    vary_uv = attr_uv;
}
