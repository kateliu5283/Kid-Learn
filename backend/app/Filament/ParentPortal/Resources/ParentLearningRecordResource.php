<?php

namespace App\Filament\ParentPortal\Resources;

use App\Filament\ParentPortal\Resources\ParentLearningRecordResource\Pages;
use App\Models\StudentLearningRecord;
use App\Support\LearningActivityLabels;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * 家長檢視名下孩子的答題／遊戲上傳紀錄（唯讀）。
 */
class ParentLearningRecordResource extends Resource
{
    protected static ?string $model = StudentLearningRecord::class;

    protected static ?string $slug = 'learning-records';

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';

    protected static ?string $navigationLabel = '答題與學習紀錄';

    protected static ?string $modelLabel = '學習紀錄';

    protected static ?string $pluralModelLabel = '答題與學習紀錄';

    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereHas(
                'student',
                fn (Builder $q) => $q->where('parent_user_id', auth()->id()),
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
                    ->label('孩子')
                    ->searchable()
                    ->sortable(),
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
                    ->label('孩子')
                    ->relationship(
                        'student',
                        'name',
                        fn (Builder $q) => $q->where('parent_user_id', auth()->id())->orderBy('sort'),
                    ),
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
            'index' => Pages\ListParentLearningRecords::route('/'),
        ];
    }
}
