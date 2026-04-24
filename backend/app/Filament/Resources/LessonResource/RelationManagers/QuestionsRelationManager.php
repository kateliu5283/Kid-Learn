<?php

namespace App\Filament\Resources\LessonResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class QuestionsRelationManager extends RelationManager
{
    protected static string $relationship = 'questions';

    protected static ?string $title = '題目';

    protected static ?string $modelLabel = '題目';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('type')
                ->label('題型')
                ->options([
                    'multiple_choice' => '選擇題',
                    'true_false' => '是非題',
                    'fill_blank' => '填空題',
                ])
                ->default('multiple_choice')
                ->required(),
            Forms\Components\Select::make('difficulty')
                ->label('難度')
                ->options(['easy' => '簡單', 'normal' => '普通', 'hard' => '困難'])
                ->default('normal'),
            Forms\Components\Textarea::make('prompt')
                ->label('題幹')
                ->rows(3)
                ->required(),
            Forms\Components\Repeater::make('options')
                ->label('選項')
                ->simple(
                    Forms\Components\TextInput::make('option')->required()
                )
                ->default(['', '', '', ''])
                ->minItems(2)
                ->maxItems(6)
                ->required(),
            Forms\Components\TextInput::make('correct_index')
                ->label('正確答案索引（從 0 開始）')
                ->numeric()
                ->default(0)
                ->required(),
            Forms\Components\Textarea::make('explanation')
                ->label('解析')
                ->rows(2),
            Forms\Components\Grid::make(2)->schema([
                Forms\Components\Toggle::make('is_published')->label('已發佈')->default(true),
                Forms\Components\Toggle::make('is_premium')->label('付費題目')->default(false),
            ]),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('prompt')
            ->columns([
                Tables\Columns\TextColumn::make('prompt')->label('題幹')->limit(50)->wrap(),
                Tables\Columns\TextColumn::make('type')
                    ->label('題型')
                    ->formatStateUsing(fn($s) => match($s) {
                        'multiple_choice' => '選擇',
                        'true_false' => '是非',
                        'fill_blank' => '填空',
                        default => $s,
                    })
                    ->badge(),
                Tables\Columns\TextColumn::make('difficulty')
                    ->label('難度')
                    ->formatStateUsing(fn($s) => match($s) {
                        'easy' => '簡單',
                        'hard' => '困難',
                        default => '普通',
                    })
                    ->badge(),
                Tables\Columns\IconColumn::make('is_published')->label('發佈')->boolean(),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        /** @var \App\Models\Lesson $lesson */
                        $lesson = $this->ownerRecord;
                        $data['subject_id'] = $lesson->subject_id;
                        $data['grade'] = $lesson->grade;
                        $data['code'] = $data['code'] ?? 'q-' . uniqid();
                        return $data;
                    }),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }
}
