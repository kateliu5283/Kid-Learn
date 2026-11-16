<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AppSessionTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_keeps_other_devices_and_replaces_the_same_device(): void
    {
        $parent = User::factory()->create([
            'role' => User::ROLE_PARENT,
            'email' => 'parent@example.com',
        ]);

        $phone = $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'password',
            'device_id' => 'phone-device-01',
            'device_label' => 'iOS',
        ])->assertOk();

        $tablet = $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'password',
            'device_id' => 'tablet-device-02',
            'device_label' => 'Android',
        ])->assertOk();

        $phoneToken = $phone->json('data.token');
        $tabletToken = $tablet->json('data.token');

        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$phoneToken,
        ])->assertOk();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$tabletToken,
        ])->assertOk();

        $phoneAgain = $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'password',
            'device_id' => 'phone-device-01',
            'device_label' => 'iOS',
        ])->assertOk();

        $this->app['auth']->forgetGuards();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$phoneToken,
        ])->assertUnauthorized();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$tabletToken,
        ])->assertOk();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$phoneAgain->json('data.token'),
        ])->assertOk();

        $this->assertSame(2, $parent->fresh()->tokens()->count());
    }

    public function test_logout_others_revokes_every_app_token_except_the_current_one(): void
    {
        $parent = User::factory()->create([
            'role' => User::ROLE_PARENT,
            'email' => 'parent@example.com',
        ]);
        $legacy = $parent->createToken('kid-learn-app')->plainTextToken;

        $phone = $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'password',
            'device_id' => 'phone-device-01',
            'device_label' => 'iOS',
        ])->assertOk()->json('data.token');

        $tablet = $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'password',
            'device_id' => 'tablet-device-02',
            'device_label' => 'Android',
        ])->assertOk()->json('data.token');

        $this->app['auth']->forgetGuards();
        $this->postJson('/api/v1/user/sessions/logout-others', [], [
            'Authorization' => 'Bearer '.$phone,
        ])->assertOk()->assertJsonPath('revoked', 2);

        $this->assertSame(1, $parent->fresh()->tokens()->count());

        $this->app['auth']->forgetGuards();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$phone,
        ])->assertOk();

        $this->app['auth']->forgetGuards();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$tablet,
        ])->assertUnauthorized();

        $this->app['auth']->forgetGuards();
        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$legacy,
        ])->assertUnauthorized();

        $sessions = $this->getJson('/api/v1/user/sessions', [
            'Authorization' => 'Bearer '.$phone,
        ])->assertOk()->json('data');

        $this->assertCount(1, $sessions);
        $this->assertTrue($sessions[0]['current']);
        $this->assertSame('iOS', $sessions[0]['label']);
    }
}
