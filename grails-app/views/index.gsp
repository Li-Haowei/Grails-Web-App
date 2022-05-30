<!doctype html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>My Web Tool</title>
    <asset:javascript src="three.js"/>
    <asset:javascript src="OrbitControls.js"/>
    <asset:javascript src="stats.min.js"/>
    <asset:javascript src="dat.gui.min.js.js"/>
    <asset:javascript src="EffectComposer.js"/>
    <asset:javascript src="RenderPass.js"/>
    <asset:javascript src="CopyShader.js"/>
    <asset:javascript src="ShaderPass.js"/>
    <asset:javascript src="MaskPass.js"/>
    <style>
        .center {
            display: flex;
            justify-content: center;
            height: 70%
        }
        #three-container{
            border-radius: 50%;
            height: 100%;
            width: 60%
        }
        #gui{
            position:absolute;
            top: 85px;
            left: 80%
        }
    </style>
</head>
<body>
<!--Top tool bar-->
<content tag="nav" >
    <!--Communication dropdown list-->
    <li class="dropdown allYellow">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" >Communication<span class="caret"></span></a>
        <ul class="dropdown-menu"   style="background: #eac086">
            <li class="dropdown-item"><a href="https://mail.google.com/mail/u/0/#inbox" target="_blank">My School Gmail</a></li>
            <li class="dropdown-item"><a href="https://mail.google.com/mail/u/1/#inbox" target="_blank">My Personal Gmail</a></li>
            <li class="dropdown-item"><a href="https://www.linkedin.com/in/haowei-li-084614164/" target="_blank">My LinkedIn</a></li>
            <li class="dropdown-item"><a href="https://github.com/Li-Haowei" target="_blank">My GitHub</a></li>
            <li class="dropdown-item"><a href="https://dev-haowei.pantheonsite.io/" target="_blank">My Personal Website</a></li>
        </ul>
    </li>
    <!--Helpful Software dropdown list-->
    <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Helpful Links<span class="caret"></span></a>
        <ul class="dropdown-menu"   style="background: #eac086">
            <li class="dropdown-item"><a href="https://learn.bu.edu/ultra/course" target="_blank">BlackBoard</a></li>
            <li class="dropdown-item"><a href="https://www.bu.edu/link/bin/uiscgi_studentlink.pl/1598588346?applpath=menu.pl&NewMenu=Home" target="_blank">Student Link</a></li>
            <li class="dropdown-item"><a href="https://www.youtube.com/" target="_blank">YouTube</a></li>
            <li class="dropdown-item"><a href="https://www.amazon.com/" target="_blank">Amazon</a></li>
            <li class="dropdown-item"><a href="https://www.gradescope.com/" target="_blank">GradeScope</a></li>
        </ul>
    </li>
    <!--Information about the web app-->
    <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">About <span class="caret"></span></a>
        <ul class="dropdown-menu dropdown-menu-right"   style="background: #eac086">
            <li class="dropdown-item"><a href="#">Controllers: ${grailsApplication.controllerClasses.size()}</a></li>
            <li class="dropdown-item"><a href="#">Domains: ${grailsApplication.domainClasses.size()}</a></li>
            <li class="dropdown-item"><a href="#">Services: ${grailsApplication.serviceClasses.size()}</a></li>
            <li class="dropdown-item"><a href="#">Tag Libraries: ${grailsApplication.tagLibClasses.size()}</a></li>
            <g:each var="plugin" in="${applicationContext.getBean('pluginManager').allPlugins}">
                <li class="dropdown-item"><a href="#">${plugin.name} - ${plugin.version}</a></li>
            </g:each>
        </ul>
    </li>
</content>



<div class="center" >
    <div id="three-container">
        <%--<asset:image src="grails-cupsonly-logo-white.svg" class="grails-logo"/>--%>
    </div>
</div>
<!--Spinning sphere-->
<script>

    // global variables
    let renderer;
    let scene;
    let camera;
    let control;
    let stats;
    let cameraControl;

    //background variable

    let cameraBG;
    let sceneBG;
    let composer;
    let clock;

    /**
     * Initializes the scene, camera and objects. Called when the window is
     * loaded by using window.onload (see below)
     */
    function init() {
        clock = new THREE.Clock();

        // create a scene, that will hold all our elements such as objects, cameras and lights.
        scene = new THREE.Scene();

        // create a camera, which defines where we're looking at.
        camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 1000);

        // create a render, sets the background color and the size
        renderer = new THREE.WebGLRenderer();
        renderer.setClearColor(0x000000, 1.0);
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.shadowMapEnabled = true;

        // create a sphere
        const sphereGeometry = new THREE.SphereGeometry(15, 30, 30);
        const sphereMaterial = createEarthMaterial();//new THREE.MeshNormalMaterial();
        const earthMesh = new THREE.Mesh(sphereGeometry, sphereMaterial);
        earthMesh.name = 'earth';
        scene.add(earthMesh);

        // create a cloudGeometry, slighly bigger than the original sphere
        const cloudGeometry = new THREE.SphereGeometry(15.3, 60, 60);
        const cloudMaterial = createCloudMaterial();
        const cloudMesh = new THREE.Mesh(cloudGeometry, cloudMaterial);
        cloudMesh.name = 'clouds';
        scene.add(cloudMesh);

        // now add some better lighting
        const ambientLight = new THREE.AmbientLight(0x111111);
        ambientLight.name='ambient';
        scene.add(ambientLight);

        // add sunlight (light
        const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
        directionalLight.position = new THREE.Vector3(100,10,-50);
        directionalLight.name='directional';
        scene.add(directionalLight);


        // position and point the camera to the center of the scene
        camera.position.x = 35;
        camera.position.y = 36;
        camera.position.z = 33;
        camera.lookAt(scene.position);

        // add controls
        cameraControl = new THREE.OrbitControls(camera);

        // add background
        cameraBG = new THREE.OrthographicCamera(-window.innerWidth, window.innerWidth, window.innerHeight, -window.innerHeight, -10000, 10000);
        cameraBG.position.z = 50;
        sceneBG = new THREE.Scene();


        const materialColor = new THREE.MeshBasicMaterial({
            map: THREE.ImageUtils.loadTexture('/assets/starry_background.jpg'),
            depthTest: false
        });
        const bgPlane = new THREE.Mesh(new THREE.PlaneGeometry(1, 1), materialColor);
        bgPlane.position.z = -100;
        bgPlane.scale.set(window.innerWidth * 2, window.innerHeight * 2, 1);
        sceneBG.add(bgPlane);

        const bgPass = new THREE.RenderPass(sceneBG, cameraBG);
        // next render the scene (rotating earth), without clearing the current output
        const renderPass = new THREE.RenderPass(scene, camera);
        renderPass.clear = false;
        // finally copy the result to the screen
        const effectCopy = new THREE.ShaderPass(THREE.CopyShader);
        effectCopy.renderToScreen = true;
        // add these passes to the composer
        composer = new THREE.EffectComposer(renderer);
        composer.addPass(bgPass);
        composer.addPass(renderPass);
        composer.addPass(effectCopy);
        // add the output of the renderer to the html element
        document.body.appendChild(renderer.domElement);

        // setup the control object for the control gui
        control = new function () {
            this.earthRotationSpeed = 0.005;
            this.cloudRotationSpeed = 0.01;
            this.opacity = 0.6;
            this.ambientLightColor = ambientLight.color.getHex();
            this.directionalLightColor = directionalLight.color.getHex();
        };

        // add extras
        addControlGui(control);

        //addStatsObject(); //removed stats


        // add the output of the renderer to the html element
        document.body.appendChild(renderer.domElement);

        // call the render function, after the first render, interval is determined
        // by requestAnimationFrame
        render();
    }

    function createEarthMaterial() {
        // 4096 is the maximum width for maps
        const earthTexture = THREE.ImageUtils.loadTexture("/assets/earthmap4k.jpg");

        const earthMaterial = new THREE.MeshPhongMaterial();
        earthMaterial.map = earthTexture;

        return earthMaterial;
    }

    function createCloudMaterial() {
        const cloudTexture = THREE.ImageUtils.loadTexture("/assets/fair_clouds_4k.png");

        const cloudMaterial = new THREE.MeshPhongMaterial();
        cloudMaterial.map = cloudTexture;
        cloudMaterial.transparent = true;

        return cloudMaterial;
    }

    function addControlGui(controlObject) {
        const gui = new dat.GUI();
        //const gui = new dat.GUI( { autoPlace: false } );
        gui.add(controlObject, 'earthRotationSpeed', -0.01, 0.01);
        gui.add(controlObject, 'cloudRotationSpeed', -0.01, 0.01);
        gui.addColor(controlObject, 'ambientLightColor');
        gui.addColor(controlObject, 'directionalLightColor');
        //gui.domElement.id = 'gui';
    }

    function addStatsObject() {
        stats = new Stats();
        stats.setMode(0);

        //stats.domElement.style.position = 'absolute';
        stats.domElement.style.left = '0px';
        stats.domElement.style.top = '0px';

        document.body.appendChild(stats.domElement);
    }


    /**
     * Called when the scene needs to be rendered. Delegates to requestAnimationFrame
     * for future renders
     */
    function render() {
        //imbed into selected item
        let container = document.getElementById('three-container');
        renderer.setSize($(container).width(), $(container).height());
        container.appendChild(renderer.domElement);

        // update stats
        //stats.update();

        resizeCanvasToDisplaySize();
        // update the camera

        cameraControl.update();

        //rotation
        scene.getObjectByName('earth').rotation.y+=control.earthRotationSpeed;
        scene.getObjectByName('clouds').rotation.y+=control.cloudRotationSpeed;

        // update light colors
        scene.getObjectByName('ambient').color = new THREE.Color(control.ambientLightColor);
        scene.getObjectByName('directional').color = new THREE.Color(control.directionalLightColor);


        // and render the scene
        renderer.render(scene, camera);

        renderer.autoClear = false;
        composer.render();
        // render using requestAnimationFrame
        requestAnimationFrame(render);
    }


    /**
     * Function handles the resize event. This make sure the camera and the renderer
     * are updated at the correct moment.
     */
    function handleResize() {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    }

    function resizeCanvasToDisplaySize() {
        const canvas = renderer.domElement;
        // look up the size the canvas is being displayed
        const width = canvas.clientWidth;
        const height = canvas.clientHeight;

        // adjust displayBuffer size to match
        if (canvas.width !== width || canvas.height !== height) {
            // you must pass false here or three.js sadly fights the browser
            renderer.setSize(width, height, false);
            camera.aspect = width / height;
            camera.updateProjectionMatrix();

            // update any render target sizes here
        }
    }

    // calls the init function when the window is done loading.
    window.onload = init;
    // calls the handleResize function when the window is resized
    //window.addEventListener('resize', handleResize, false);

</script>

</body>
</html>
