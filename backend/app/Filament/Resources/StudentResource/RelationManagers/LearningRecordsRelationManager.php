<?php

namespace App\Filament\Resources\StudentResource\RelationManagers;

use App\Models\StudentLearningRecord;
use App\Support\LearningActivityLabels;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class LearningRecordsRelationManager extends RelationManager
{
    protected static string $relationship = 'learningRecords';

    protected static ?string $title = '答題與學習紀錄';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('activity_type')
            ->columns([
                Tables\Columns\TextColumn::make('activity_type')
                    ->label('類型')
                    ->formatStateUsing(fn (string $state): string => LearningActivityLabels::label($state)),
                Tables\Columns\TextColumn::make('title')->label('標題')->placeholder('—')->limit(32),
                Tables\Columns\TextColumn::make('score')
                    ->label('成績')
                    ->state(fn (StudentLearningRecord $r): string => "{$r->correct_count}／{$r->question_count}".($r->score_percent !== null ? "（{$r->score_percent}%）" : '')),
                Tables\Columns\TextColumn::make('recorded_at')
                    ->label('紀錄時間')
                    ->dateTime('Y-m-d H:i'),
            ])
            ->headerActions([])
            ->defaultSort('recorded_at', 'desc');
    }
}
