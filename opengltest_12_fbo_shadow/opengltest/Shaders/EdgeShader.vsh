attribute highp vec3 attr_pos;
attribute mediump vec3 attr_normal;
uniform highp mat4 unif_cammat4;
uniform mediump float unif_edgesize;

void main()
{
    gl_Position = unif_cammat4 * vec4(attr_pos + (attr_normal * unif_edgesize), 1.0) ;
    //gl_Position = unif_cammat4 * attr_pos;
}