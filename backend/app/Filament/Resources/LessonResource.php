<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LessonResource\Pages;
use App\Filament\Resources\LessonResource\RelationManagers;
use App\Models\Lesson;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class LessonResource extends Resource
{
    protected static ?string $model = Lesson::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';

    protected static ?string $navigationGroup = '課程內容';

    protected static ?string $modelLabel = '課程單元';

    protected static ?string $pluralModelLabel = '課程單元';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('基本資訊')->schema([
                Forms\Components\Grid::make(2)->schema([
                    Forms\Components\TextInput::make('code')
                        ->label('單元代碼')
                        ->helperText('例如：cl-c-1-1-u1')
                        ->required()
                        ->unique(ignoreRecord: true)
                        ->maxLength(64),
                    Forms\Components\Select::make('subject_id')
                        ->label('學科')
                        ->relationship('subject', 'name')
                        ->required()
                        ->searchable()
                        ->preload(),
                ]),
                Forms\Components\TextInput::make('title')
                    ->label('單元名稱')
                    ->required()
                    ->maxLength(128),
                Forms\Components\Textarea::make('summary')
                    ->label('單元摘要')
                    ->rows(2)
                    ->maxLength(500),
                Forms\Components\Grid::make(3)->schema([
                    Forms\Components\Select::make('grade')
                        ->label('年級')
                        ->options([1 => '1 年級', 2 => '2 年級', 3 => '3 年級', 4 => '4 年級', 5 => '5 年級', 6 => '6 年級'])
                        ->required(),
                    Forms\Components\Select::make('semester')
                        ->label('學期')
                        ->options(['first' => '上學期', 'second' => '下學期']),
                    Forms\Components\TextInput::make('unit')
                        ->label('單元編號')
                        ->numeric()
                        ->minValue(1),
                ]),
                Forms\Components\Select::make('track')
                    ->label('課綱軸')
                    ->options(['core' => '課綱', 'extended' => '素養', 'general' => '一般'])
                    ->default('core'),
            ]),

            Forms\Components\Section::make('學習內容')->schema([
                Forms\Components\Textarea::make('content')
                    ->label('課文內容')
                    ->rows(8),
                Forms\Components\TextInput::make('estimated_minutes')
                    ->label('預計學習時間（分鐘）')
                    ->numeric()
                    ->default(10),
                Forms\Components\TagsInput::make('objectives')
                    ->label('學習目標')
                    ->helperText('每項目一個 tag'),
                Forms\Components\TagsInput::make('key_points')
                    ->label('重點整理')
                    ->helperText('每點一個 tag'),
            ])->collapsible(),

            Forms\Components\Section::make('上架設定')->schema([
                Forms\Components\Grid::make(3)->schema([
                    Forms\Components\Toggle::make('is_published')->label('已發佈')->default(true),
                    Forms\Components\Toggle::make('is_premium')->label('付費單元')->default(false),
                    Forms\Components\TextInput::make('sort')->label('排序')->numeric()->default(0),
                ]),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('subject.name')->label('學科')->badge()->sortable(),
                Tables\Columns\TextColumn::make('grade')->label('年級')->formatStateUsing(fn($state) => "{$state} 年級")->sortable(),
                Tables\Columns\TextColumn::make('semester')
                    ->label('學期')
                    ->formatStateUsing(fn($state) => $state === 'first' ? '上' : ($state === 'second' ? '下' : '-')),
                Tables\Columns\TextColumn::make('unit')->label('單元'),
                Tables\Columns\TextColumn::make('title')->label('單元名稱')->searchable()->limit(30),
                Tables\Columns\TextColumn::make('questions_count')
                    ->label('題數')
                    ->counts('questions')
                    ->badge()
                    ->color('success'),
                Tables\Columns\IconColumn::make('is_published')->label('發佈')->boolean(),
                Tables\Columns\IconColumn::make('is_premium')
                    ->label('付費')
                    ->boolean()
                    ->trueIcon('heroicon-o-lock-closed')
                    ->falseIcon('heroicon-o-lock-open')
                    ->trueColor('warning'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('subject_id')
                    ->label('學科')
                    ->relationship('subject', 'name'),
                Tables\Filters\SelectFilter::make('grade')
                    ->label('年級')
                    ->options([1 => '1', 2 => '2', 3 => '3', 4 => '4', 5 => '5', 6 => '6']),
                Tables\Filters\TernaryFilter::make('is_published')->label('已發佈'),
                Tables\Filters\TernaryFilter::make('is_premium')->label('付費單元'),
            ])
            ->defaultSort('sort')
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\QuestionsRelationManager::class,
            RelationManagers\VocabularyItemsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListLessons::route('/'),
            'create' => Pages\CreateLesson::route('/create'),
            'edit' => Pages\EditLesson::route('/{record}/edit'),
        ];
    }
}
