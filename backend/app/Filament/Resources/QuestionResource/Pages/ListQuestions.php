<?php

namespace App\Filament\Resources\QuestionResource\Pages;

use App\Filament\Resources\QuestionResource;
use App\Models\Lesson;
use App\Models\Subject;
use App\Services\Content\AiQuestionGenerator;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;

class ListQuestions extends ListRecords
{
    protected static string $resource = QuestionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('aiGenerate')
                ->label('AI 出題')
                ->icon('heroicon-o-sparkles')
                ->modalHeading('AI 產生選擇題（待審核）')
                ->modalDescription('產生的題目為「待審核」且不會出現在 App API，請於列表中核准後才會發佈。')
                ->form([
                    Forms\Components\Select::make('subject_id')
                        ->label('學科')
                        ->options(fn () => Subject::query()->orderBy('sort')->pluck('name', 'id'))
                        ->searchable()
                        ->required(),
                    Forms\Components\Select::make('grade')
                        ->label('年級')
                        ->options([1 => '1 年級', 2 => '2 年級', 3 => '3 年級', 4 => '4 年級', 5 => '5 年級', 6 => '6 年級'])
                        ->required(),
                    Forms\Components\Select::make('lesson_id')
                        ->label('綁定課程（可選）')
                        ->options(fn () => Lesson::query()->orderBy('title')->pluck('title', 'id'))
                        ->searchable(),
                    Forms\Components\TextInput::make('count')
                        ->label('題數')
                        ->numeric()
                        ->default(5)
                        ->minValue(1)
                        ->maxValue(20)
                        ->required(),
                    Forms\Components\Textarea::make('topic_focus')
                        ->label('主題／範圍（可選）')
                        ->rows(2)
                        ->placeholder('例如：兩位數加法、注音結合韻、天氣變化…'),
                ])
                ->action(function (array $data): void {
                    try {
                        /** @var AiQuestionGenerator $gen */
                        $gen = app(AiQuestionGenerator::class);
                        $created = $gen->generate(
                            (int) $data['subject_id'],
                            (int) $data['grade'],
                            (int) $data['count'],
                            isset($data['lesson_id']) ? (int) $data['lesson_id'] : null,
                            isset($data['topic_focus']) ? trim((string) $data['topic_focus']) : null,
                        );
                        Notification::make()
                            ->title('已產生 '.count($created).' 題（待審核）')
                            ->success()
                            ->send();
                    } catch (\Throwable $e) {
                        Notification::make()
                            ->title('AI 出題失敗')
                            ->body($e->getMessage())
                            ->danger()
                            ->send();
                    }
                }),
            Actions\CreateAction::make(),
        ];
    }
}
