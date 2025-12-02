'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "cf071e17f78c44556a81ed67e02fb65e",
"icons/Icon-maskable-512.png": "cf071e17f78c44556a81ed67e02fb65e",
"icons/Icon-192.png": "eea7af6e4fcb0bfa906e8114478a1519",
"icons/Icon-maskable-192.png": "eea7af6e4fcb0bfa906e8114478a1519",
"manifest.json": "5848b7d29863940fcc247cce9755660b",
"logo_preview.png": "cefec68e8893f09a6d9e0d9976a7fba0",
"index.html": "1b8393fc534d0b073d505104a9f13e2b",
"/": "1b8393fc534d0b073d505104a9f13e2b",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "313afea68c7968deffd3f36ecfedbfe6",
"assets/assets/images/highlights_unit_header.jpeg": "5e4f7d086162de4af6e1d9b8afe3eac6",
"assets/assets/images/teacher_admin.png": "25b3b69015992aac2ca8364811163679",
"assets/assets/images/logo_preview.png": "cefec68e8893f09a6d9e0d9976a7fba0",
"assets/assets/images/malestudent.png": "c5bcaaf48b57fa4e4f15e264ac8bcb27",
"assets/assets/images/course_placeholder.jpeg": "060bfa69c5a5d19299b7baba27f5b26a",
"assets/assets/images/teacher_admin_female.png": "d034b4547b7698b1f1949c3355a61ff2",
"assets/assets/images/logo.png": "4e69ed445477a3cf4738584c1170f28d",
"assets/assets/images/femalestudent.png": "a2fa1d8e5fb4ea9201c2e30bd8f13dbe",
"assets/assets/images/defaultavatar.jpg": "976602238067a18a641432c53200c701",
"assets/assets/pdfs/lessonPdfPlacehokder.pdf": "da7706ff8a902065764da1aa4b1cc046",
"assets/assets/animations/Profile%2520Tap.json": "9ba72f6c5d55317130f29baac0fab49a",
"assets/assets/animations/redWarning.json": "ffb677fa1b5d654f48a031ecbe409eb7",
"assets/assets/animations/No%2520Enrolled%2520Courses.json": "e02a97e99d24c50a4c29ebc30b91b6f0",
"assets/assets/animations/Notification%2520Tap.json": "494d21d75321da9c0960c5071092d9c7",
"assets/assets/animations/checked.json": "100a63a6674ec25fa68c53e4df97205b",
"assets/assets/animations/Empty%2520Highlight%2520List.json": "69b61387db02c49f0a0e34dc3c26f0a7",
"assets/assets/animations/Success.json": "586b3bd4279518a30afc2c6ce8c1f198",
"assets/assets/animations/Emailsent.json": "20d0ca3c268693805809d609b8db82b4",
"assets/assets/animations/Empty%2520Notification%2520List.json": "1f8cb2aec0b29067d9ea26898ac2a617",
"assets/assets/animations/Empty%2520Students%2520List.json": "094b7aa2c17b593fbc1ffb355729a3bd",
"assets/assets/animations/Add%2520To%2520Cart%2520Success.json": "92b2434e0c7008ddae793dcd46ab00c2",
"assets/assets/animations/Vision%2520Tap.json": "4299b53ab3e916dc0dd127523f21414d",
"assets/assets/animations/empty%2520exams%2520list.json": "c3d69c2b24500d6a95dcfe491809cf44",
"assets/assets/animations/yellowWarning.json": "c4d257578281bf4f8be99cab13d84733",
"assets/assets/animations/Home%2520Tap.json": "72c8495f6c4ac238f2ebad2dbf2af033",
"assets/assets/animations/Error.json": "f2289101127619e06ed21d1956840a1d",
"assets/assets/animations/examsTap.json": "13bafd3e6f609fcc18dcd65310914f95",
"assets/assets/animations/Menu.json": "59068411a33b859f52215b952b207fd7",
"assets/assets/animations/Flyingperson.json": "7408cb948dfaaedb7851393883f62599",
"assets/assets/animations/Trophy.json": "06363136e1a81639b8ae12789528088c",
"assets/assets/animations/shopping%2520cart.json": "c791107fbbb1f1addb0d6fc7fd4aedf2",
"assets/assets/animations/No%2520Internet%2520Connection.json": "e27ea6a26eeaa9670364f60af24901f7",
"assets/assets/animations/Empty%2520Courses%2520List.json": "12657f4822dc91de1c5d49ee01e2d6d3",
"assets/assets/animations/Verification%2520Badge.json": "6d6a24d886207904a339ef09c223c553",
"assets/assets/animations/Courses%2520Tap.json": "43befd05d69f12d74acd456d01072d3f",
"assets/assets/animations/Celebration.json": "ff63a9b38d34fece66ab25e011855e49",
"assets/fonts/MaterialIcons-Regular.otf": "18433ff9db5dcc85c8499716fb14f79e",
"assets/NOTICES": "97576e84288946bf5d69f35ce2873cfc",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "05c1294957b930233a7c3cb124ec2b7f",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "1fcba7a59e49001aa1b4409a25d425b0",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "75ceb91d26663253a0d353c4e5ca7b6b",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/youtube_player_flutter/assets/speedometer.webp": "50448630e948b5b3998ae5a5d112622b",
"assets/FontManifest.json": "c75f7af11fb9919e042ad2ee704db319",
"assets/AssetManifest.bin": "300c1f8e01407aab05a94689214fca77",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "9ea055952f796152fbe2ce6d850e3d04",
"flutter_bootstrap.js": "1c28fac93773d32b7bc6419c4e995274",
"version.json": "7ec2287613e41a144f4be0ff8c0164a4",
"main.dart.js": "4d19fc27cfadc8b3f2a2f16a06ca717d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
