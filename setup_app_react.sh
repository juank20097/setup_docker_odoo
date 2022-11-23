#Variables
v1=/home/juank/reactApp
v2=/home/juank/Documents/grive
echo "------------------------------------------------------"
echo "----------------Creacion de la Aplicacion-------------"
echo "------------------------------------------------------"
cd $v1
read -p "Introduce el nombre de la Aplicación:" app
npx react-native init $app
cd $app
echo "------------------------------------------------------"
echo "----Instalación WebView and Pagina de Carga-------------"
echo "------------------------------------------------------"
yarn add react-native-webview
rm App.js
cp $v2/App.js $v1/$app
read -p "Introduzca la url de la aplicación:" url
sed -i -e 's%name_url%'$url'%g' "App.js"
echo "------------------------------------------------------"
echo "----------------Manejo de Recursos--------------------"
echo "------------------------------------------------------"
read -p "Introduzca la dirección de los recursos:" dir
cd $v1/$app/android/app/src/main/res
rm -r mipmap*
cd $dir/android
cp -r mipmap* $v1/$app/android/app/src/main/res
for i in $(ls -d mipmap*); do
        cd $v1/$app/android/app/src/main/res/$i
        cp ic_launcher.png ic_launcher_round.png
done
echo "------------------------------------------------------"
echo "----------------Verificación de Dispositivo-----------"
echo "------------------------------------------------------"
adb kill-server
adb start-server
adb devices
read -p "El dispositivo está conectado (yes/no):" device
if [ $device = 'yes' ] ; then
	cd $v1/$app
	npx react-native run-android
	npx react-native start
fi
echo "------------------------------------------------------"
echo "----------------Creación del APK y AAB----------------"
echo "------------------------------------------------------"
read -p "La Aplicación Funciona de forma correcta (yes/no):" result
if [ $result = 'yes' ] ; then
	#Generacion de key
	cd $v1/$app/android/app
	keytool -genkey -v -keystore mykeystore.keystore -alias mykeyalias -keyalg RSA -keysize 2048 -validity 10000
	#clave:Emelecjce123
	cd $v1/$app/android
	rm gradle.properties
	cp $v2/gradle.properties $v1/$app/android
	cd $v1/$app/android/app
	rm build.gradle
	cp $v2/build.gradle $v1/$app/android/app
	#Generacion de APK y AAB
	cd $v1/$app
	mkdir aplicacion
	cd android && ./gradlew assembleRelease
	cp $v1/$app/android/app/build/outputs/apk/release/app-release.apk $v1/$app/aplicacion/$app.apk
	cd $v1/$app
	cd android && ./gradlew bundleRelease
	cp $v1/$app/android/app/build/outputs/bundle/release/app-release.aab $v1/$app/aplicacion/$app.aab
fi
