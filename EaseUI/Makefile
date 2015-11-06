PROJECT_NAME="EaseUI.xcodeproj"
CC=xcodebuild
TARGET_NAME=${target_name}
SDK_VERSION=${sdk_ver}
CONFIGURATION=${configuration}
DEVICE_ARCHS="armv7 armv7s arm64"
SIMULATOR_ARCHS="i386 x86_64"

all:compile

compile:
	echo target=${TARGET_NAME} configuration=${CONFIGURATION} project=${PROJECT_NAME} sdk=iphonesimulator${SDK_VERSION} ARCHS=${SIMULATOR_ARCHS}
	${CC} -target ${TARGET_NAME} -configuration ${CONFIGURATION} -project ${PROJECT_NAME} -sdk iphonesimulator${SDK_VERSION} ARCHS=${SIMULATOR_ARCHS} VALID_ARCHS=${SIMULATOR_ARCHS}

	echo target=${TARGET_NAME} configuration=${CONFIGURATION} project=${PROJECT_NAME} sdk=iphoneos${SDK_VERSION} ARCHS=${DEVICE_ARCHS}
	${CC} -target ${TARGET_NAME} -configuration ${CONFIGURATION} -project ${PROJECT_NAME} -sdk iphoneos${SDK_VERSION} ARCHS=${DEVICE_ARCHS} VALID_ARCHS=${DEVICE_ARCHS}

clean:
	echo target=${TARGET_NAME} configuration=${CONFIGURATION} project=${PROJECT_NAME} sdk=iphonesimulator${SDK_VERSION}
	${CC} clean -target ${TARGET_NAME} -configuration ${CONFIGURATION} -sdk iphonesimulator${SDK_VERSION} -project ${PROJECT_NAME}

	echo target=${TARGET_NAME} configuration=${CONFIGURATION} project=${PROJECT_NAME} sdk=iphoneos${SDK_VERSION}
	${CC} clean -target ${TARGET_NAME} -configuration ${CONFIGURATION} -sdk iphoneos${SDK_VERSION} -project ${PROJECT_NAME}
