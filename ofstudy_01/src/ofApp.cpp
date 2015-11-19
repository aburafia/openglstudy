#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
	ofBackground(34, 34, 34);
	ofSetVerticalSync(false);
	ofEnableAlphaBlending();
    
    
		
	//we load a font and tell OF to make outlines so we can draw it as GL shapes rather than textures
	font.load("type/verdana.ttf", 100, true, false, true, 0.4, 72);
	#ifdef TARGET_OPENGLES
	shader.load("shaders_gles/noise.vert","shaders_gles/noise.frag");
	#else
	if(ofIsGLProgrammableRenderer()){
		shader.load("shaders_gl3/noise.vert", "shaders_gl3/noise.frag");
	}else{
		shader.load("shaders/noise.vert", "shaders/noise.frag");
	}
	#endif

	doShader = true;
    
    model.loadModel("ball.stl");
    
    //cam1.setPosition(ofGetWidth()/2, (float)ofGetHeight()/2 , -500);
    cam1.setPosition(0, 0 , -500);
    cam1.lookAt(ofVec3f(0,0,0));
}

//--------------------------------------------------------------
void ofApp::update(){

}

//--------------------------------------------------------------
void ofApp::draw(){

	ofSetColor(225);
	ofDrawBitmapString("'s' toggles shader", 10, 20);

    string str = ofToString(mouseX - ofGetWidth()/2);
    ofDrawBitmapString("mouseX=" + str, 50, 50);
    
	ofSetColor(245, 58, 135);
	ofFill();
	
    cam1.begin();
    
	if( doShader ){
		shader.begin();
        
			//we want to pass in some varrying values to animate our type / color 
			shader.setUniform1f("timeValX", ofGetElapsedTimef() * 0.1 );
			shader.setUniform1f("timeValY", -ofGetElapsedTimef() * 0.18 );
			
			//we also pass in the mouse position 
			//we have to transform the coords to what the shader is expecting which is 0,0 in the center and y axis flipped. 
			shader.setUniform2f("mouse", mouseX - ofGetWidth()/2, ofGetHeight()/2-mouseY );
        
        
        
	}
    

	
		//finally draw our text
		//font.drawStringAsShapes("openFrameworks", 90, 260);

        model.setScale(0.4, 0.4, 0.3);
        model.setPosition(0, 0 , 0);
        model.drawFaces();
    
	
	if( doShader ){
		shader.end();
	}
    
    //string str = ofToString(mouseX - ofGetWidth()/2);
    ofDrawBitmapString("mouseX=" + str, 0, 0, -10);

    
    cam1.end();
}

//--------------------------------------------------------------
void ofApp::keyPressed  (int key){ 
	if( key == 's' ){
		doShader = !doShader;
	}	
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){ 
	
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){
	
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
	
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
	
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}

