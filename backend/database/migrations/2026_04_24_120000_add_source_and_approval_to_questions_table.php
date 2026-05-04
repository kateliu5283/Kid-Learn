<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questions', function (Blueprint $table) {
            $table->string('source', 16)->default('manual')->after('code');
            $table->string('approval_status', 16)->default('approved')->after('source');
            $table->timestamp('reviewed_at')->nullable()->after('approval_status');
            $table->foreignId('reviewed_by')->nullable()->after('reviewed_at')->constrained('users')->nullOnDelete();
            $table->string('ai_model', 128)->nullable()->after('reviewed_by');
            $table->index(['approval_status', 'source']);
        });
    }

    public function down(): void
    {
        Schema::table('questions', function (Blueprint $table) {
            $table->dropForeign(['reviewed_by']);
            $table->dropIndex(['approval_status', 'source']);
            $table->dropColumn(['source', 'approval_status', 'reviewed_at', 'reviewed_by', 'ai_model']);
        });
    }
};
