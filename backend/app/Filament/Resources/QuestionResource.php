<?php

namespace App\Filament\Resources;

use App\Filament\Resources\QuestionResource\Pages;
use App\Models\Question;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class QuestionResource extends Resource
{
    protected static ?string $model = Question::class;

    protected static ?string $navigationIcon = 'heroicon-o-question-mark-circle';

    protected static ?string $navigationGroup = '課程內容';

    protected static ?string $modelLabel = '題目';

    protected static ?string $pluralModelLabel = '題目';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('題目資訊')->schema([
                Forms\Components\Grid::make(2)->schema([
                    Forms\Components\TextInput::make('code')
                        ->label('題目代碼')
                        ->helperText('例如：q-math-1-001；不填會自動產生')
                        ->maxLength(64)
                        ->unique(ignoreRecord: true),
                    Forms\Components\Select::make('type')
                        ->label('題型')
                        ->options([
                            'multiple_choice' => '選擇題',
                            'true_false' => '是非題',
                            'fill_blank' => '填空題',
                        ])
                        ->default('multiple_choice')
                        ->required(),
                ]),
                Forms\Components\Grid::make(3)->schema([
                    Forms\Components\Select::make('subject_id')
                        ->label('學科')
                        ->relationship('subject', 'name')
                        ->required()
                        ->searchable()
                        ->preload(),
                    Forms\Components\Select::make('grade')
                        ->label('年級')
                        ->options([1 => '1 年級', 2 => '2 年級', 3 => '3 年級', 4 => '4 年級', 5 => '5 年級', 6 => '6 年級'])
                        ->required(),
                    Forms\Components\Select::make('difficulty')
                        ->label('難度')
                        ->options(['easy' => '簡單', 'normal' => '普通', 'hard' => '困難'])
                        ->default('normal')
                        ->required(),
                ]),
                Forms\Components\Select::make('lesson_id')
                    ->label('綁定課程（可選）')
                    ->relationship('lesson', 'title')
                    ->searchable()
                    ->preload()
                    ->helperText('若此題屬於某課程，選擇課程；否則留空為延伸題庫'),
            ]),

            Forms\Components\Section::make('題目內容')->schema([
                Forms\Components\Textarea::make('prompt')
                    ->label('題幹')
                    ->rows(3)
                    ->required(),
                Forms\Components\Repeater::make('options')
                    ->label('選項')
                    ->helperText('新增 2-6 個選項')
                    ->simple(
                        Forms\Components\TextInput::make('option')
                            ->label('選項內容')
                            ->required()
                    )
                    ->default(['', '', '', ''])
                    ->minItems(2)
                    ->maxItems(6)
                    ->reorderable()
                    ->required(),
                Forms\Components\TextInput::make('correct_index')
                    ->label('正確答案索引')
                    ->helperText('從 0 開始，例如第 1 個選項填 0')
                    ->numeric()
                    ->minValue(0)
                    ->maxValue(5)
                    ->default(0)
                    ->required(),
                Forms\Components\Textarea::make('explanation')
                    ->label('解析（答題後顯示）')
                    ->rows(2),
                Forms\Components\TextInput::make('image_url')
                    ->label('題目圖片 URL')
                    ->url(),
                Forms\Components\TagsInput::make('tags')->label('標籤'),
            ]),

            Forms\Components\Section::make('上架設定')->schema([
                Forms\Components\Grid::make(3)->schema([
                    Forms\Components\Toggle::make('is_published')->label('已發佈')->default(true),
                    Forms\Components\Toggle::make('is_premium')->label('付費題目')->default(false),
                    Forms\Components\TextInput::make('sort')->label('排序')->numeric()->default(0),
                ]),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('subject.name')->label('學科')->badge(),
                Tables\Columns\TextColumn::make('grade')->label('年級')->formatStateUsing(fn($s) => "{$s} 年級"),
                Tables\Columns\TextColumn::make('prompt')
                    ->label('題幹')
                    ->limit(40)
                    ->searchable()
                    ->wrap(),
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
                    ->badge()
                    ->color(fn($state) => match($state) {
                        'easy' => 'success',
                        'hard' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('lesson.title')->label('所屬課程')->limit(20)->placeholder('—'),
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
                Tables\Filters\SelectFilter::make('difficulty')
                    ->label('難度')
                    ->options(['easy' => '簡單', 'normal' => '普通', 'hard' => '困難']),
                Tables\Filters\TernaryFilter::make('is_published')->label('已發佈'),
                Tables\Filters\TernaryFilter::make('is_premium')->label('付費題目'),
            ])
            ->defaultSort('id', 'desc')
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('publish')
                        ->label('批次發佈')
                        ->icon('heroicon-o-check-circle')
                        ->action(fn($records) => $records->each->update(['is_published' => true])),
                    Tables\Actions\BulkAction::make('unpublish')
                        ->label('批次下架')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(fn($records) => $records->each->update(['is_published' => false])),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListQuestions::route('/'),
            'create' => Pages\CreateQuestion::route('/create'),
            'edit' => Pages\EditQuestion::route('/{record}/edit'),
        ];
    }
}
