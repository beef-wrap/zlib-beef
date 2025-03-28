import { type Build } from 'xbuild';

const build: Build = {
    common: {
        project: 'libpng',
        archs: ['x64'],
        variables: [],
        copy: {},
        defines: [],
        options: [
            ['ZLIB_BUILD_SHARED', false],
        ],
        subdirectories: ['zlib'],
        libraries: {
            zlibstatic: {
                name: 'zlib'
            }
        },
        buildDir: 'build',
        buildOutDir: '../libs',
        buildFlags: []
    },
    platforms: {
        win32: {
            windows: {},
            android: {
                archs: ['x86', 'x86_64', 'armeabi-v7a', 'arm64-v8a'],
            }
        },
        linux: {
            linux: {}
        },
        darwin: {
            macos: {}
        }
    }
}

export default build;