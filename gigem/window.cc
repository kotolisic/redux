#include "gigatron.h"

// Обработчик кадра
uint WindowTimer(uint interval, void *param) {

    SDL_Event     event;
    SDL_UserEvent userevent;

    /* Создать новый Event */
    userevent.type  = SDL_USEREVENT;
    userevent.code  = 0;
    userevent.data1 = NULL;
    userevent.data2 = NULL;

    event.type = SDL_USEREVENT;
    event.user = userevent;

    SDL_PushEvent(&event);
    return (interval);
}

// Конструктор
Gigatron::Gigatron(int w, int h, const char* caption) {

    width  = w;
    height = h;

    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
    SDL_EnableUNICODE(1);

    sdl_screen = SDL_SetVideoMode(w, h, 32, SDL_HWSURFACE | SDL_DOUBLEBUF);
    SDL_WM_SetCaption(caption, 0);

    // Инициализация процессора
    procstart();
}

// Обработчик событий с окна
void Gigatron::start() {

    int k, i, keyid, mk;

    while (1) {

        while (SDL_PollEvent(& event)) {

            switch (event.type) {

                // Если нажато на крестик, то приложение будет закрыто
                case SDL_QUIT:
                    return;

                case SDL_MOUSEMOTION:
                    break;

                // Нажата какая-то клавиша
                case SDL_KEYDOWN: {

                    // keyid = get_key(event);
                    break;
                }

                // Отпущена клавиша
                case SDL_KEYUP: {

                    // keyid = get_key(event);
                    break;
                }

                // Вызывается по таймеру
                case SDL_USEREVENT:

                    SDL_Flip(sdl_screen);
                    break;
            }
        }

        SDL_Delay(1);
    }
}
