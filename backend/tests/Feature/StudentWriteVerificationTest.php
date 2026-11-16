<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StudentWriteVerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_unverified_parent_can_list_but_not_change_students(): void
    {
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 1,
            'device_local_id' => 'p1',
            'sort' => 0,
        ]);
        $token = $parent->createToken('kid-learn:device-1|iOS')->plainTextToken;
        $auth = ['Authorization' => 'Bearer '.$token];

        $this->getJson('/api/v1/user/students', $auth)
            ->assertOk()
            ->assertJsonPath('data.0.name', '小華');

        $this->postJson('/api/v1/user/students', [
            'name' => '小明',
            'grade' => 2,
        ], $auth)->assertForbidden()->assertJsonPath('code', 'email_unverified');

        $this->putJson('/api/v1/user/students/'.$student->id, [
            'name' => '改名',
        ], $auth)->assertForbidden()->assertJsonPath('code', 'email_unverified');

        $this->deleteJson('/api/v1/user/students/'.$student->id, [], $auth)
            ->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');

        $this->assertDatabaseHas('students', ['id' => $student->id, 'name' => '小華']);
    }

    public function test_verified_parent_can_create_a_student(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $token = $parent->createToken('kid-learn:device-1|iOS')->plainTextToken;

        $this->postJson('/api/v1/user/students', [
            'name' => '小明',
            'grade' => 2,
            'device_local_id' => 'local-2',
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertCreated()->assertJsonPath('data.name', '小明');
    }
}
