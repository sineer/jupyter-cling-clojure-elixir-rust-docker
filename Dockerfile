FROM pprzetacznik/ielixir-requirements

ENV WORK_DIR=/opt

USER root

RUN apt install -y \
    libzmq3-dev \
    libsqlite3-dev

RUN set -xe \
  && sudo apt-get update \
  && sudo apt install -y jupyter-notebook cmake build-essential \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y \
  && ${HOME}/.cargo/bin/rustup component add rust-src \
  && curl -s https://api.github.com/repos/pprzetacznik/IElixir/releases/latest \
     | grep "tarball_url" | sed -n -e 's/.*tarball_url": "\(.*\)".*/\1/p' | xargs -t curl -fSL -o ielixir.tar.gz \
  && mkdir ielixir \
  && tar -zxvf ielixir.tar.gz -C ielixir --strip-components=1 \
  && rm ielixir.tar.gz \
  && cd ielixir \
  && ls -alh \
  && mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get \
  && mix deps.compile \
  && ./install_script.sh \
  && chmod -R 777 /home/jovyan/ \
  && pip install jupyterlab_code_formatter \
  && conda update -n base conda \
  && conda install -c conda-forge jupyterlab_code_formatter \
  && pip install black isort \
  && conda install black isort \
  && conda install --quiet --yes 'jupyter_console' \
  && conda install -y -c simplect clojupyter \
  && conda install xeus-cling -c conda-forge \
  && ${HOME}/.cargo/bin/cargo install evcxr_jupyter \
  && evcxr_jupyter --install

USER $NB_UID

CMD ["start-notebook.sh"]
