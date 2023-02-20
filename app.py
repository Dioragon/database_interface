import warnings
warnings.filterwarnings("ignore", category=FutureWarning)
from flask import abort, render_template, Flask
import logging
import db

APP = Flask(__name__)

# Start page
@APP.route('/')
def index():
    stats = {}
    x = db.execute('SELECT COUNT(*) AS estudantes FROM ESTUDANTE').fetchone()
    stats.update(x)
    x = db.execute('SELECT COUNT(*) AS departamentos FROM DEPARTAMENTO').fetchone()
    stats.update(x)
    x = db.execute('SELECT COUNT(*) AS eventos FROM EVENTO').fetchone()
    stats.update(x)
    x = db.execute('SELECT COUNT(*) AS publicacoes FROM PUBLICACAO').fetchone()
    stats.update(x)
    x = db.execute('SELECT COUNT(*) AS reunioes FROM REUNIAO').fetchone()
    stats.update(x)
    logging.info(stats)
    return render_template('index.html',stats=stats)

# Inicializa db
# Assume que existe um script chamado db.sql na pasta sql
@APP.route('/init/')
def init(): 
    return render_template('init.html', init=db.init())

# Estudantes -------------------------------------------------------------------------------------
@APP.route('/estudantes/')
def list_estudantes():
    estudantes = db.execute(
        '''
        SELECT Id, Nome, CursoNome, DATE(Adesao) AS DataAdesao
        FROM ESTUDANTE
        ORDER BY Nome, Adesao
        '''
    ).fetchall()
    return render_template('estudante-list.html', estudantes = estudantes)

@APP.route('/estudantes/search/<expr>/')
def search_estudante(expr):
    search = { 'expr': expr }
    expr = '%' + expr + '%'
    estudantes = db.execute(
        ''' 
        SELECT Id, Nome, CursoNome, DATE(Adesao) AS DataAdesao
        FROM ESTUDANTE
        WHERE Nome LIKE %s
        ORDER BY Nome, Adesao
        ''', expr
    ).fetchall()
    return render_template('estudante-search.html', search=search, estudantes=estudantes)

@APP.route('/estudantes/<int:id>/')
def show_estudante(id):
    estudante = db.execute(
        '''
        SELECT *
        FROM ESTUDANTE
        WHERE Id = %s
        ''', id
    ).fetchone()
    if estudante is None:
        abort(404, 'Estudante Id {} does not exist.'.format(id))
    telemovel = {}
    if not (estudante['Telemovel'] is None):
        telemovel = db.execute(
            '''
            SELECT Telemovel
            FROM ESTUDANTE
            WHERE Id = %s
            ''', id
        ).fetchone()
    mentor = {}
    if not (estudante['Mentor'] is None):
        mentor = db.execute(
            '''
            SELECT Nome
            FROM ESTUDANTE
            WHERE Id = %s
            ''', estudante['Mentor']
        ).fetchone()
    mentorados = []
    mentorados = db.execute(
        '''
        SELECT Id, Nome
        FROM ESTUDANTE
        WHERE Mentor = %s
        ORDER BY Nome
        ''', id
    ).fetchall()
    departamentos = db.execute(
        '''
        SELECT Id, Nome
        FROM DEPARTAMENTO JOIN MEMBRO ON(Departamento = Id)
        WHERE Estudante = %s
        ''', id
    ).fetchall()
    presidente = db.execute(
        '''
        SELECT Departamento, Presidente
        FROM PRESIDENTE
        WHERE Presidente = %s
        ''', id
    ).fetchone()
    return render_template('estudante.html', 
        estudante=estudante, mentor=mentor, mentorados=mentorados,
        departamentos=departamentos, telemovel=telemovel, presidente=presidente)

# Departamentos -----------------------------------------------------------------------------------------
@APP.route('/departamentos/')
def list_departamentos():
    departamentos = db.execute(
        '''
        SELECT D.Id AS IdD, D.Nome AS NomeD,
        COUNT(*) AS Membros, E.Nome AS NomeP, Presidente
        FROM DEPARTAMENTO D JOIN MEMBRO M ON(M.Departamento = D.Id)
        JOIN PRESIDENTE P ON(P.Departamento = D.Id)
        JOIN ESTUDANTE E ON(Presidente = E.Id)
        GROUP BY D.Id;
        '''
    ).fetchall()
    return render_template('departamento-list.html', departamentos=departamentos)

@APP.route('/departamentos/<int:id>/')
def show_departamento(id):
    departamento = db.execute(
        '''
        SELECT *
        FROM DEPARTAMENTO
        WHERE Id = %s
        ''', id
    ).fetchone()
    if departamento is None:
        abort(404, 'Departmento Id {} does not exist.'.format(id))
    presidente = db.execute(
        '''
        SELECT Id, Nome
        FROM PRESIDENTE JOIN ESTUDANTE ON(Presidente = Id)
        WHERE Departamento = %s
        ''', id
    ).fetchone()
    nm = db.execute(
        '''
        SELECT COUNT(*) AS N
        FROM MEMBRO
        WHERE Departamento = %s
        ''', id
    ).fetchone()
    membros = db.execute(
        '''
        SELECT Id, Nome
        FROM ESTUDANTE JOIN MEMBRO ON(Estudante = Id)
        WHERE Departamento = %s
        ORDER BY Nome
        ''', id
    ).fetchall()
    ne = {}
    np = {}
    eventos = []
    publicacoes = []
    if departamento['Nome'] == 'Educacional' or departamento['Nome'] == 'Ludico':
        ne = db.execute(
            '''
            SELECT COUNT(*) AS N
            FROM ORGANIZADOR
            WHERE Departamento = %s
            ''', id
        ).fetchone()
        eventos = db.execute(
            '''
            SELECT Id, Nome
            FROM EVENTO JOIN ORGANIZADOR ON(Evento = Id)
            WHERE Departamento = %s
            ''', id
        ).fetchall()
    elif departamento['Nome'] == 'Divulgacao':
        np = db.execute(
            '''
            SELECT COUNT(*) AS N
            FROM PUBLICACAO
            '''
        ).fetchone()
        publicacoes = db.execute(
            '''
            SELECT Evento, Nome
            FROM EVENTO JOIN PUBLICACAO ON(Evento = Id)
            '''
        ).fetchall()
    return render_template('departamento.html',
        departamento=departamento, presidente=presidente, membros=membros,
        eventos=eventos, publicacoes=publicacoes, nm=nm, ne=ne, np=np)

# Eventos -----------------------------------------------------------------------------------------------
@APP.route('/eventos/')
def list_eventos():
    eventos = db.execute(
        '''
        SELECT E.Id AS IdE, D.Id AS IdD,
        E.Nome AS NomeE, D.Nome AS NomeD, Inicio
        FROM EVENTO E JOIN ORGANIZADOR ON(Evento = E.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        ORDER BY Inicio
        '''
    ).fetchall()
    return render_template('evento-list.html', eventos=eventos)

@APP.route('/eventos/search/<expr>/')
def search_evento(expr):
    search = { 'expr': expr }
    expr = '%' + expr + '%'
    eventos = db.execute(
        ''' 
        SELECT E.Id AS IdE, D.Id AS IdD,
        E.Nome AS NomeE, D.Nome AS NomeD, Inicio
        FROM EVENTO E JOIN ORGANIZADOR ON(Evento = E.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        WHERE E.Nome LIKE %s
        ORDER BY E.Nome, Inicio
        ''', expr
    ).fetchall()
    return render_template('evento-search.html', search=search, eventos=eventos)

@APP.route('/eventos/<int:id>')
def show_evento(id):
    evento = db.execute(
        '''
        SELECT E.Id AS IdE, D.Id AS IdD, E.Nome AS NomeE,
        D.Nome AS NomeD, Inicio, Fim, Descricao
        FROM EVENTO E JOIN ORGANIZADOR ON(Evento = E.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        WHERE E.Id = %s
        ''', id
    ).fetchone()
    if evento is None:
        abort(404, 'Evento Id {} does not exist.'.format(id))
    oradores = db.execute(
        '''
        SELECT Nome
        FROM ORADOR
        WHERE Evento = %s
        ''', id
    ).fetchall()
    return render_template('evento.html', evento=evento, oradores=oradores)

# Publicações --------------------------------------------------------------------------------------------
@APP.route('/publicacoes/')
def list_publicacoes():
    publicacoes = db.execute(
        '''
        SELECT Nome, Evento, Data
        FROM PUBLICACAO JOIN EVENTO ON(Evento = Id)
        ORDER BY Data
        '''
    ).fetchall()
    return render_template('publicacao-list.html', publicacoes=publicacoes)

@APP.route('/publicacoes/<int:id>')
def show_publicacao(id):
    publicacao = db.execute(
        '''
        SELECT Evento, Imagem, P.Descricao AS DescricaoP, Data, Nome
        FROM PUBLICACAO P JOIN EVENTO E ON(Evento = Id)
        WHERE Evento = %s
        ''', id
    ).fetchone()
    if publicacao is None:
        abort(404, 'Publicacao Id {} does not exist'.format(id))
    divulgacao = db.execute(
        '''
        SELECT Id
        FROM DEPARTAMENTO
        WHERE Nome = 'Divulgacao'
        '''
    ).fetchone()
    return render_template('publicacao.html', publicacao=publicacao, divulgacao=divulgacao)

# Reuniões -----------------------------------------------------------------------------------------------
@APP.route('/reunioes/')
def list_reunioes():
    reunioes = db.execute(
        '''
        SELECT R.Id AS IdR, D.Id as IdD, Geral, Inicio, Fim, Nome
        FROM REUNIAO R JOIN CONVOCADOR ON(Reuniao = R.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        ORDER BY Inicio
        '''
    ).fetchall()
    return render_template('reuniao-list.html', reunioes=reunioes)

@APP.route('/reunioes/searchdata/<expr>/')
def search_reuniao_data(expr):
    search = { 'expr': expr }
    reunioes = db.execute(
        ''' 
        SELECT R.Id AS IdR, D.Id as IdD, Geral, Inicio, Fim, Nome
        FROM REUNIAO R JOIN CONVOCADOR ON(Reuniao = R.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        WHERE DATE(Inicio) = %s
        ORDER BY Inicio
        ''', expr
    ).fetchall()
    return render_template('reuniao-search.html', search=search, reunioes=reunioes)

@APP.route('/reunioes/searchdepartamento/<expr>/')
def search_reuniao_departamento(expr):
    search = { 'expr': expr }
    expr = '%' + expr + '%'
    reunioes = db.execute(
        ''' 
        SELECT R.Id AS IdR, D.Id as IdD, Geral, Inicio, Fim, Nome
        FROM REUNIAO R JOIN CONVOCADOR ON(Reuniao = R.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        WHERE Nome LIKE %s
        ORDER BY Inicio
        ''', expr
    ).fetchall()
    return render_template('reuniao-search.html', search=search, reunioes=reunioes)

@APP.route('/reunioes/<int:id>')
def show_reuniao(id):
    reuniao = db.execute(
        '''
        SELECT R.Id AS IdR, D.Id AS IdD, Geral, Inicio, Fim, Nome
        FROM REUNIAO R JOIN CONVOCADOR ON(Reuniao = R.Id)
        JOIN DEPARTAMENTO D ON(Departamento = D.Id)
        WHERE R.Id = %s
        ''', id
    ).fetchone()
    if reuniao is None:
        abort(404, 'Reuniao Id {} does not exist.'.format(id))
    assuntos = db.execute(
        '''
        SELECT Assunto
        FROM ASSUNTO
        WHERE Reuniao = %s
        ''', id
    ).fetchall()
    conclusoes = db.execute(
        '''
        SELECT Conclusao
        FROM CONCLUSOES
        WHERE Reuniao = %s
        ''', id
    ).fetchall()
    participantes = db.execute(
        '''
        SELECT Id, Nome
        FROM REUNIDOS JOIN ESTUDANTE ON(Participante = Id)
        WHERE Reuniao = %s
        ''', id
    ).fetchall()
    return render_template('reuniao.html', reuniao=reuniao, assuntos=assuntos,
        conclusoes=conclusoes, participantes=participantes)