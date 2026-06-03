#version 460 core
#include <flutter/runtime_effect.glsl>

// Uniform 선언 순서 = 인덱스 순서
uniform float uTime;        // index 0  — 연속 시간 (초)
uniform vec2  uResolution;  // index 1,2 — 캔버스 크기 (px)
uniform vec2  uTouchPoint;  // index 3,4 — 터치 좌표 (px, raw)
uniform float uProgress;    // index 5  — 리플 수명 [0.0 .. 1.0]

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv    = fragCoord / uResolution;
    vec2 touch = uTouchPoint / uResolution;

    // 종횡비 보정 거리 (원형 유지)
    float aspect = uResolution.x / uResolution.y;
    vec2 d = uv - touch;
    d.x *= aspect;
    float dist = length(d);

    // 확장하는 리플 링 (브랜치 없이 smoothstep)
    float radius = uProgress * 0.9;
    float ring   = smoothstep(0.06, 0.0, abs(dist - radius));

    // 유기적 파동 굴절
    float wave = sin(dist * 42.0 - uTime * 6.2831) * 0.5 + 0.5;

    // 터치 지점 네온 글로우
    float glow = smoothstep(0.45, 0.0, dist);

    // 수명에 따른 페이드 아웃
    float life = 1.0 - uProgress;

    // 브랜드 그린 → 화이트 하이라이트
    vec3 brand = vec3(0.114, 0.725, 0.329); // #1DB954
    vec3 color = mix(brand, vec3(1.0), wave * ring);

    float alpha = clamp(ring * 0.55 + glow * 0.12, 0.0, 1.0) * life;
    fragColor = vec4(color * alpha, alpha);
}
