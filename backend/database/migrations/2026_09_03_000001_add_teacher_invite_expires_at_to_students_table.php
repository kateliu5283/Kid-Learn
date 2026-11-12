<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $table->timestamp('teacher_invite_expires_at')->nullable()->after('teacher_invite_token');
        });

        // 既有邀請連結給 24 小時寬限期，之後需家長重新產生
        DB::table('students')
            ->whereNotNull('teacher_invite_token')
            ->whereNull('teacher_invite_expires_at')
            ->update(['teacher_invite_expires_at' => now()->addDay()]);
    }

    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $table->dropColumn('teacher_invite_expires_at');
        });
    }
};
