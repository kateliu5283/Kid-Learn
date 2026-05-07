<?php

namespace App\Filament\Teacher\Resources;

use App\Filament\Teacher\Resources\StudentLearningRecordResource\Pages;
use App\Models\StudentLearningRecord;
use App\Support\LearningActivityLabels;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * 教師檢視「teacher_student」指派學生的上傳紀錄（唯讀）。
 */
class StudentLearningRecordResource extends Resource
{
    protected static ?string $model = StudentLearningRecord::class;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';

    protected static ?string $navigationLabel = '學生答題紀錄';

    protected static ?string $modelLabel = '學習紀錄';

    protected static ?string $pluralModelLabel = '學生答題紀錄';

    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereHas(
                'student',
                fn (Builder $q) => $q->whereHas(
                    'teachers',
                    fn (Builder $t) => $t->where('users.id', auth()->id()),
                ),
            );
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function canDelete($record): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('student.name')
                    ->label('學生')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('student.parent.email')
                    ->label('家長 Email')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('activity_type')
                    ->label('類型')
                    ->formatStateUsing(fn (string $state): string => LearningActivityLabels::label($state))
                    ->sortable(),
                Tables\Columns\TextColumn::make('title')
                    ->label('標題')
                    ->placeholder('—')
                    ->limit(40),
                Tables\Columns\TextColumn::make('score')
                    ->label('成績')
                    ->state(fn (StudentLearningRecord $r): string => "{$r->correct_count}／{$r->question_count}".($r->score_percent !== null ? "（{$r->score_percent}%）" : '')),
                Tables\Columns\TextColumn::make('duration_seconds')
                    ->label('秒數')
                    ->placeholder('—')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('recorded_at')
                    ->label('紀錄時間')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('student_id')
                    ->label('學生')
                    ->options(function (): array {
                        /** @var \App\Models\User $u */
                        $u = auth()->user();

                        return $u->taughtStudents()->orderBy('name')->pluck('name', 'id')->all();
                    }),
                Tables\Filters\SelectFilter::make('activity_type')
                    ->label('類型')
                    ->options(LearningActivityLabels::options()),
            ], layout: FiltersLayout::AboveContent)
            ->filtersFormColumns(2)
            ->defaultSort('recorded_at', 'desc')
            ->actions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudentLearningRecords::route('/'),
        ];
    }
}
